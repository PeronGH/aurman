# aurman

Opinionated AUR Management Scripts

## Usage

```sh
aurman.sh <command> [args...]
```

## Commands

| Command | Description |
|---------|-------------|
| `install <package>...` | Clone the AUR repo, review the PKGBUILD, and build with `makepkg -si` after confirmation |
| `list` | List cloned packages with their installed and PKGBUILD versions |
| `update` | Pull all cloned repos and run `install` on packages whose PKGBUILD version differs from the installed one |

## Install

Add `bin/` to your `PATH`:

```sh
echo "export PATH=\"$PWD/bin:\$PATH\"" >> ~/.bash_profile
```

Reload with `source ~/.bash_profile`.
