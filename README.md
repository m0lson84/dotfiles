# 👨‍💻 Personal Dotfiles

Cross platform configuration and environment setup managed by [chezmoi](https://www.chezmoi.io/).

> Currently a work in progress

## Installation

To install chezmoi as well as the defined configurations, following command:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --purge-binary --apply m0lson84
```

The `--purge-binary` flag will remove the binary after the installation is done. Chezmoi will install itself using the preferred package manager on the system.
