# VOL (OLCS) Development tools

## Shared git aliases
Run the following command to add the shared aliases:

```bash
git config --add --global include.path /path/to/olcs-devtools/gitconfig-shared
```

When adding commands make sure to prefix them with `vol-` and make sure they only use commands available on windows' git
bash, linux and mac.

Do not use `git vol-each` for dangerous commands like `push`.
