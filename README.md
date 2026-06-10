# aurman

Opinionated AUR Management Scripts

## Usage

```sh
aurman.sh <command> [args...]
```

## Commands

| Command | Description |
|---------|-------------|
| `install <package>...` | Clone the AUR repo, review the PKGBUILD and any install scripts or hooks, and build with `makepkg -si` after confirmation |
| `list` | List cloned packages with their installed and PKGBUILD versions |
| `uninstall <package>...` | Remove all installed packages of the base with `pacman -Rns` and delete the clone |
| `update [<package>...]` | Pull cloned repos and run `install` on packages whose PKGBUILD version differs from the installed one; with arguments, only those packages |

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
