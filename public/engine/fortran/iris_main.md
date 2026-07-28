# Iris Unified Command Dispatcher (`iris_main`)

## Overview
The `iris_main` program serves as the unified dispatcher executable (`iris`) for the Iris Typographic Suite. Each mode operates as its own dedicated standalone program (`iris-tex`, `iris-kpsewhich`, `iris-trip`, `iris-compile`), while the `iris` command acts as a dispatcher forwarding arguments to the appropriate executable command.

## Usage
```bash
iris [subcommand] [options] [arguments]
```

## Subcommands
- `tex`: Dispatch to `iris-tex` to compile TeX documents.
- `kpsewhich`: Dispatch to `iris-kpsewhich` to resolve TeX path locations.
- `trip`: Dispatch to `iris-trip` to run the TRIP benchmark suite.
- `compile`: Dispatch to `iris-compile` to compile Iris markup/prose to PDF.
- `[file]`: Default mode dispatches to `iris-compile`.

## Help Commands
- `iris --help`: Display dispatcher subcommands and options.
- `iris tex --help`: Display help for `iris-tex`.
- `iris kpsewhich --help`: Display help for `iris-kpsewhich`.
- `iris trip --help`: Display help for `iris-trip`.
- `iris compile --help`: Display help for `iris-compile`.

