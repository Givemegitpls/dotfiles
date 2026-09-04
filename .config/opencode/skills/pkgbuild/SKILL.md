---
name: pkgbuild
description: Use when writing, editing, or reviewing an Arch Linux PKGBUILD (including Rust, Python, VCS/-git packages, and .SRCINFO). Covers required variables, build/package functions, cargo/Rust specifics, VCS pkgver(), checksums, and namcap verification.
---

# PKGBUILD (Arch Linux packaging)

Справочник по написанию PKGBUILD. Источники: ArchWiki
[PKGBUILD](https://wiki.archlinux.org/title/PKGBUILD),
[Rust package guidelines](https://wiki.archlinux.org/title/Rust_package_guidelines),
[VCS package guidelines](https://wiki.archlinux.org/title/VCS_package_guidelines).
Проверяй каждый флаг в этой справке против актуальной wiki перед написанием нестандартного пакета.

## Обязательные переменные

- `pkgname` — строка из строчных букв/цифр/`@._+-`, без ведущих `-`/`.`; обычно = имени бинарника.
- `pkgver` — версия upstream, БЕЗ дефиса (дефис заменяется на `_`). `pkgver` двигается при новом upstream-релизе.
- `pkgrel` — целое, начиная с 1; бампается при изменении PKGBUILD без смены `pkgver`; сбрасывается в 1 при новом релизе.
- `arch` — `('x86_64')` для бинарей; `('any')` для архитектурно-независимых (скрипты/шрифты).
- `license` — SPDX-идентификатор, напр. `license=('MIT')`. Сильно рекомендуется. Для кастомной лицензии — `custom:имя` + установить файл в `/usr/share/licenses/$pkgname/`.

Порядок переменных обычно: `pkgname, pkgver, pkgrel, pkgdesc, url, license, makedepends, depends, arch, source, sha256sums` (или `b2sums`). Порядок не обязателен, но общепринят.

## Зависимости

- `depends` — нужны и для сборки, и для запуска. Перечислять ВСЕ прямые первого уровня, даже если уже тянутся транзитивно.
- `makedepends` — только для сборки. `base-devel` НЕ включать (подразумевается makepkg).
- `checkdepends` — только для `check()` (тесты).
- `optdepends` — опционально; формат `'пакет: что даёт'`.
- Архитектурно-специфичные варианты: `depends_x86_64=()`, `source_x86_64=()` и т.п.

## source и checksums

- `source=()` — URL или имена локальных файлов. Формат: `'уникальное_имя::URL'` (уникальность обязательна, т.к. SRCDEST общий).
- checksum-массив обязан 1:1 соответствовать `source`:
  `sha256sums=()`, `b2sums=()` (предпочтительнее), `sha512sums=()` и т.д.
- Генерация/обновление: `updpkgsums` (из pacman-contrib) или `makepkg -g >> PKGBUILD`.
- Берется НАИБОЛЕЕ сильная сумма из публикуемых upstream: `b2 > sha512 > sha384 > sha256 > sha224 > sha1 > md5`.

## Стандартные функции

```sh
prepare() { :; }   # патчи, cargo fetch, распаковка вручную
build()   { :; }   # компиляция
check()   { :; }   # тесты (запускается при --check)
package() { :; }   # установка файлов в "$pkgdir"
```

`package()` обязательна; остальные опциональны. `pkgdir`/`srcdir`/`startdir` задаёт makepkg.

## Rust-проект (бинарный крейт)

Следовать [Rust package guidelines](https://wiki.archlinux.org/title/Rust_package_guidelines):

```sh
pkgname=my-tool            # = имени бинарника, без версии
makedepends=('cargo')      # rust throttles cargo+rustc
arch=('x86_64')            # бинарь — архитектурно-зависимый
source=("$pkgname-$pkgver.tar.gz::https://static.crates.io/crates/$pkgname/$pkgname-$pkgver.crate")
# если релиз на GitHub: source=("$pkgname-$pkgver.tar.gz::https://github.com/u/$pkgname/archive/v$pkgver.tar.gz")

prepare() {
  export RUSTUP_TOOLCHAIN=stable
  cargo fetch --locked --target "$(rustc -vV | sed -n 's/host: //p')"
}

build() {
  export RUSTUP_TOOLCHAIN=stable
  export CARGO_TARGET_DIR=target
  cargo build --frozen --release --all-features
}

check() {
  export RUSTUP_TOOLCHAIN=stable
  cargo test --frozen --all-features
}

package() {
  install -Dm0755 -t "$pkgdir/usr/bin/" "target/release/$pkgname"
}
```

Ключевые флаги cargo:

- `--locked` / `--frozen` — строго по `Cargo.lock`, без сетевых апдейтов (воспроизводимость). `--frozen = --locked --offline`.
- `--release` — release-сборка.
- `--all-features` — все фичи; иначе явно `--features f1,f2`.
- `CARGO_TARGET_DIR=target` — выхлоп в локальный `target/`, не в `~/.cargo`.
- `RUSTUP_TOOLCHAIN=stable` — фикс при сборке вне chroot, где дефолт пользователя сломан.

Заметки:

- Rust бинари статически линкуют большинство зависимостей → `depends` пустой или только `glibc`/`libgcc`. `makedepends=(cargo)`.
- LTO может ломать сборку крейтов с нативным C/C++ (`ring` и т.п.): отключать LTO или развязывать `-sys` крейты через `*_NO_VENDOR=1` / `*_USE_PKG_CONFIG=1`.
- Если нужны доп. файлы (man, assets) и нет иного способа → `cargo install --no-track --frozen --all-features --root "$pkgdir/usr/" --path .` (без `build()`).
- Workspace: `[workspace]` в Cargo.toml → `cargo test --workspace`.
- Тесты не гонять с `--release` (оптимизации отключают `debug_assert!`/переполнения).

## VCS / -git пакет

Следовать [VCS package guidelines](https://wiki.archlinux.org/title/VCS_package_guidelines):

- Суффикс имени: `pkgname=foo-git` (или `-svn`, `-hg`, `-bzr`), кроме случая фиксации конкретного релиза.
- `source=('foo::git+https://example.org/foo.git')` — `vcs+` нужен для URL, где тип VCS не виден; `folder::` задаёт имя локальной папки.
- `#branch=`, `#tag=`, `#commit=` — фрагменты для конкретной ветки/тега/коммита.
- `sha256sums=('SKIP')` — источники нестатичны, контрольная сумма не считается (кроме `#tag`/`#commit` — тогда можно `makepkg -g`).
- `makedepends` дополнить самим VCS-инструментом (`git`, `svn`, ...).
- Versioning: `RELEASE.rREVISION`. Без релизов/тегов — `rREVISION`. Разделитель `r` перед ревизией важен для монотонности.
- `pkgver()` — автобамп версии. Для git используй subshell с `set -o pipefail`, иначе fallback НЕ сработает и `pkgver` станет пустым:
  ```sh
  pkgver() {
    cd "$pkgname"
    ( set -o pipefail
      git describe --long --tags --abbrev=7 2>/dev/null \
        | sed 's/\([^-]*-g\)/r\1/;s/-/./g' \
        || printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short=7 HEAD)"
    )
  }
  ```
  Ловушка: без `pipefail` статус пайпа `git describe | sed` равен статусу ПОСЛЕДНЕЙ команды (`sed`). При отсутствии тегов `git describe` падает (ошибка уходит в `2>/dev/null`), но `sed` из пустого входа возвращает 0 → `||` не срабатывает → stdout пуст → makepkg падает с `pkgver is not allowed to be empty`. Вариант «без тегов» даёт `rN.COMMIT` (`git rev-list --count HEAD` + `git rev-parse --short=7 HEAD`), с тегами — `tag.rN.gCOMMIT`.
- `provides`/`conflicts` для паралки к стабильному пакету: `provides=("foo=${pkgver}")`, `conflicts=('foo')`. `replaces=()` избегать.
- Не использовать `pkgver` в поле `folder` (меняется внутри `pkgver()`).

## Ловушки makepkg (обязательно)

- **Не запускать `makepkg` в корне исходников проекта.** По умолчанию `SRCDEST`/`srcdir` = текущая папка → `makepkg` клонирует source в `./pkgname/` (bare) и распаковывает в `./src/`, замусоривая настоящий исходник и `.git`. Собирать в отдельной чистой папке: `mkdir /tmp/pkg && cp PKGBUILD /tmp/pkg/ && cd /tmp/pkg && makepkg -si`.
- **`build()`/`package()` выполняются в `$srcdir` = распакованный source** (обычно `src/`), НЕ в корне, где лежит PKGBUILD. Локальные файлы (LICENSE, иконки, конфиги), которые не попали в source-архив/repo, не видны относительным путём → `install: cannot stat 'LICENSE'`. Варианты: (а) закоммитить файл в upstream-репу, (б) добавить его отдельным элементом `source=()` с checksum, (в) использовать `"$startdir/LICENSE"` (makepkg задаёт `startdir` = папка PKGBUILD).

## Проверка

- `namcap PKGBUILD` и `namcap имя.pkg.tar.zst` — ловит типовые ошибки упаковки.
- `shellcheck --shell=bash --exclude=SC2034,SC2154,SC2164 PKGBUILD` — bash-ошибки.
- `makepkg --printsrcinfo` — сгенерировать `.SRCINFO` (для AUR).
- Сухая проверка синтаксиса без сборки: `bash -n PKGBUILD`.

Прототипы: `/usr/share/pacman/PKGBUILD.proto`, `/usr/share/pacman/PKGBUILD-vcs.proto` (из пакета `pacman`).

## Последовательность действий для нового пакета

1. Узнать upstream: имя бинарника, версия, источник (crates.io / GitHub tarball / git), лицензия, deps.
2. Заполнить обязательные переменные + source/checksums.
3. Написать `prepare()`/`build()`/`check()`/`package()` под тип проекта (Rust → см. выше).
4. `updpkgsums`, если тarball-источник (не VCS).
5. `namcap` + `shellcheck` + `bash -n`.
6. `makepkg -si` (или `--printsrcinfo` для AUR + `.SRCINFO`).
