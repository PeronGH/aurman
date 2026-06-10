# aurman

Opinionated AUR Management Scripts

## Usage

```sh
aurman.sh <command> [args...]
```

## Commands

| Command | Description |
|---------|-------------|
| `install <package>...` | Clone, review the PKGBUILD and hooks, build after confirmation |
| `list` | Show cloned packages with installed and PKGBUILD versions |
| `uninstall <package>...` | `pacman -Rns` the base's packages and delete the clone |
| `update [<package>...]` | Pull clones (all, or just those named) and `install` the outdated ones |

## Install

Add `bin/` to your `PATH`:

```sh
echo "export PATH=\"$PWD/bin:\$PATH\"" >> ~/.bash_profile
```

Reload with `source ~/.bash_profile`.

## Development

Scripts are formatted with [shfmt](https://github.com/mvdan/sh) (settings in `.editorconfig`) and linted with [ShellCheck](https://www.shellcheck.net/):

```sh
shfmt -w bin/aurman.sh bin/applets/*.sh
shellcheck bin/aurman.sh bin/applets/*.sh
```
