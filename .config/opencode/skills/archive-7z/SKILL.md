---
name: archive-7z
description: "Use when listing, extracting, or creating archives (.zip, .jar, .7z, .tar.gz, etc.) and unzip/jar are unavailable. Covers 7z list, extract, and add commands with common switches."
---

# Archive operations with 7z

The system has no `unzip` or `jar` — use `7z` for all archive operations.

## Why

7-Zip handles zip, jar, 7z, tar, gz, and many other formats. It is the single
archive tool available on this machine.

## Commands

### List contents

```
7z l <archive>
```

- Add `-r` to recurse into nested archives.
- Add `-slt` for technical details (sizes, CRC, timestamps) in list output.

### Extract

```
7z x <archive>
```

- `x` preserves directory structure (use `e` to flatten, not recommended).
- `-o<dir>` — extract to a specific directory (no space after `-o`).
  Example: `7z x archive.zip -o/tmp/extracted`
- `-y` — assume Yes on all overwrite prompts (useful in scripts).
- `-p<password>` — for encrypted archives.

### Add / create

```
7z a <archive> <files...>
```

- Format is inferred from the extension (`.zip`, `.7z`, `.tar.gz`, etc.).
- `-r` — recurse subdirectories.
- `-mx<N>` — compression level 1 (fastest) .. 9 (ultra). Default is 5.
- `-p<password>` — encrypt archive with password.

### Other commands

| Command | Purpose |
|---------|---------|
| `7z t <archive>` | Test archive integrity |
| `7z d <archive> <files>` | Delete files from archive |
| `7z u <archive> <files>` | Update files in archive |
| `7z h <files>` | Calculate hash values |

## Common formats

| Extension | Format detection |
|-----------|----------------|
| `.zip` | ZIP |
| `.jar` | ZIP (Java archive) |
| `.7z` | 7-Zip native |
| `.tar.gz` | gzip-compressed tar |
| `.tar` | uncompressed tar |

(verified against `7z --help`, 7-Zip 26.02 x64)