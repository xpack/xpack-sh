# xpack-sh

Bash scripts to experiment with xPack command line tools

These scripts are intended to provide partial functionality until the final node.js applications will be ready.

## Installing

There is no need for a special install procedure, cloning the GitHub repo is enough:

```
$ git clone https://github.com/xpack/xpack-sh.git "${HOME}/Downloads/xpack-sh.git"
```

## Invoking

The `xpm` script can be invoked directly:

```
$ bash "${HOME}/Downloads/xpack-sh.git/xpm.sh"
```

Similarly for the `xmake` script:

```
$ bash "${HOME}/Downloads/xpack-sh.git/xpm.sh"
```

## Debug help

The scripts can be started with `-x` to view each command executed:

```
$ export DEBUG=-x
$ bash "${HOME}/Downloads/xpack-sh.git/xpm.sh"
```

When the DEBUG is no longer needed, unset it:

```
$ unset DEBUG
```

