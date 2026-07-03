---
name: ci
description:
  Use when creating or modifying GitLab CI pipelines for APS projects. Covers CI
  components registry, image-build, release, docs, and pipeline conventions.
---

# GitLab CI Pipeline (APS)

## CI Components Registry

Components are hosted at `git.apsolutions.ru/aps/Internal/common/ci-components`.
Always check the latest version tag in that repo before pinning. Component
source templates live in `templates/` within the repo.

## Available Components

### image-build

Builds a Docker image and pushes to Harbor registry. Uses Buildkit (`buildx`)
running in Kubernetes.

```yaml
- component: git.apsolutions.ru/aps/Internal/common/ci-components/image-build@<VERSION>
  inputs:
    image_name: $HARBOR_URL/internal/$CI_PROJECT_NAME # REQUIRED - no default
    dockerfile: ./Dockerfile # default: ./Dockerfile
    docker_context_path: . # default: .
    image_tag: $CI_COMMIT_SHORT_SHA # default: $CI_COMMIT_SHORT_SHA
    buildkit_addr: tcp://buildkitd.buildkit.svc.cluster.local:1234
    job_name: build # default: build
    stage: build # default: build
    extra_args: "" # space-separated KEY=VALUE pairs
```

**Inputs:**

| Input                 | Default                | Description                                             |
| --------------------- | ---------------------- | ------------------------------------------------------- |
| `image_name`          | **required**           | Full image name with registry path                      |
| `dockerfile`          | `./Dockerfile`         | Path to Dockerfile                                      |
| `docker_context_path` | `.`                    | Build context directory                                 |
| `image_tag`           | `$CI_COMMIT_SHORT_SHA` | Image tag (overridden to `$CI_COMMIT_TAG` on tags)      |
| `job_name`            | `build`                | CI job name                                             |
| `stage`               | `build`                | Pipeline stage                                          |
| `extra_args`          | `""`                   | Additional build args, e.g. `KEY1=$VALUE1 KEY2=$VALUE2` |

**Behavior:**

- Tags image as both `:latest` and `:$APP_VERSION`
- Passes `COMMIT_SHORT` and `APP_VERSION` as build args automatically
- Uses registry cache (`--cache-to` / `--cache-from`)
- Runs on kubernetes runners
- Builds `linux/amd64` only
- Runs on all branches AND tags (on tags, `APP_VERSION` is set to the tag name)

### release

Creates GitLab release + Mattermost notification. Only runs on tags.

```yaml
- component: git.apsolutions.ru/aps/Internal/common/ci-components/release@<VERSION>
  inputs:
    stage: release # default: release
    mattermost_webhook: $MATTERMOST_RELEASE_WEBHOOK # default: http://localhost
```

### docs

Builds mkdocs site and syncs to S3 bucket.

```yaml
- component: git.apsolutions.ru/aps/Internal/common/ci-components/docs@<VERSION>
  inputs:
    bucket_name: my-bucket # REQUIRED
    build_job_name: docs-static # default: docs-static
    push_job_name: push-docs # default: push-docs
    build_stage: build # default: build
    push_stage: deploy # default: deploy
    image: harbor.apsolutions.ru/base/mkdocs-material:9.6.18-2
    s3_endpoint: http://objectnode.cubefs-test.aps
```

### push_archrepo_golang

Builds a Go project into an Arch Linux package and publishes to a custom pacman
repo. Only runs on tags or manual trigger.

```yaml
- component: git.apsolutions.ru/aps/Internal/common/ci-components/push_archrepo_golang@<VERSION>
  inputs:
    repo_name: myrepo # REQUIRED
    pkgbuild_dir: archlinux/pkg # REQUIRED
    pkgname: mypackage # REQUIRED
    job_name: push-archrepo # default: push_archrepo
    stage: build # default: build
```

### python-linters

Runs pyright and ruff.

```yaml
- component: git.apsolutions.ru/aps/Internal/common/ci-components/python-linters@<VERSION>
  inputs:
    python_ci_version: "3.13"
    ruff_version: "0.4.4"
    stage: lint
    root_path: .
```

## Pipeline Conventions

### Standard stages

```yaml
stages:
  - build
  - test
  - deploy
  - release
```

### Workflow rules

Skip MR pipelines, run on everything else:

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      when: never
    - when: always
```

Optionally skip `deploy` branch:

```yaml
workflow:
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
      when: never
    - if: $CI_COMMIT_BRANCH == "deploy"
      when: never
    - when: always
```

### Common variables

```yaml
variables:
  GOPRIVATE: git.apsolutions.ru
  GIT_PASSWORD: $CI_JOB_TOKEN
  GIT_USER: ci-job-token
```

Use `GOPRIVATE` for Go projects. Use `GIT_USER`/`GIT_PASSWORD` when Dockerfiles
need to clone private repos (pass via `extra_args: GIT_PASSWORD=$CI_JOB_TOKEN`).

### Go test job pattern

```yaml
test:
  stage: test
  image: "harbor.apsolutions.ru/dockerhub/golang:<VERSION>-bookworm"
  needs: []
  allow_failure: true
  script:
    - go install github.com/jstemmer/go-junit-report/v2@latest
    - go mod download
    - go test ./... -v | go-junit-report -set-exit-code > report.xml
  artifacts:
    when: always
    paths:
      - report.xml
    reports:
      junit: report.xml
```

### Multi-service monorepo pattern

When a repo has multiple Dockerfiles (e.g. services in subdirectories), include
one `image-build` component per service with different `job_name`, `dockerfile`,
and `docker_context_path`:

```yaml
include:
  - component: git.apsolutions.ru/aps/Internal/common/ci-components/image-build@<VERSION>
    inputs:
      image_name: $HARBOR_URL/internal/$CI_PROJECT_NAME-service-a
      dockerfile: ./services/service-a/Dockerfile
      docker_context_path: ./services/service-a
      job_name: service-a
      stage: build
  - component: git.apsolutions.ru/aps/Internal/common/ci-components/image-build@<VERSION>
    inputs:
      image_name: $HARBOR_URL/internal/$CI_PROJECT_NAME-service-b
      dockerfile: ./services/service-b/Dockerfile
      docker_context_path: ./services/service-b
      job_name: service-b
      stage: build
```

### Merge-to-deploy-branch job

For projects that auto-merge main into a `deploy` branch after successful
builds:

```yaml
merge-to-deploy-branch:
  stage: deploy
  needs:
    - <build-job-name>
  image:
    name: harbor.apsolutions.ru/dockerhub/alpine/git:latest
    entrypoint: [""]
  before_script:
    - git config --global user.email "ci@example.com"
    - git config --global user.name "GitLab CI"
    - git remote set-url origin
      https://gitlab-ci-token:${CI_JOB_TOKEN}@${CI_SERVER_HOST}/${CI_PROJECT_PATH}.git
  script:
    - git remote prune origin
    - git fetch origin deploy $CI_COMMIT_SHA
    - git checkout -B deploy origin/deploy
    - git merge --ff-only $CI_COMMIT_SHA
    - git push origin deploy
  only:
    - main
  when: on_success
```

## Image Naming Convention

- Single image: `$HARBOR_URL/internal/$CI_PROJECT_NAME`
- Multi-service: `$HARBOR_URL/internal/$CI_PROJECT_NAME-<service>`
- Custom name: `$HARBOR_URL/internal/<name>`

## Important Notes

1. **All build jobs run on kubernetes runners** (`tags: [kubernetes]`)
2. **Harbor registry credentials** are injected via `$DOCKER_AUTH_CONFIG` CI
   variable (pre-configured in component)
3. **Base images** should use `harbor.apsolutions.ru/dockerhub/` mirror prefix
   for Docker Hub images (e.g.
   `harbor.apsolutions.ru/dockerhub/library/golang:1.26-alpine`)
4. **Component versions**: pin to a specific version tag. Check
   `git.apsolutions.ru/aps/Internal/common/ci-components` for the latest.
5. **`extra_args` format**: space-separated `KEY=$VALUE` pairs. Values with `$`
   are resolved in the CI job context.
6. **Prefer `rules:` over `only:`/`except:`**: the latter are deprecated in modern
   GitLab CI; use `rules:` for new jobs (existing `only:` examples above still work
   but are not recommended for new pipelines).
