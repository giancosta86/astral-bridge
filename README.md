# astral-bridge

_Bridge between the Elvish shell and NodeJS_

![Logo](./logo.jpg)

**astral-bridge** is a lightweight but effective library seamlessly connecting the [Elvish](https://elv.sh/) shell with the [NodeJS](https://nodejs.org/en) ecosystem.

## Installation

The library can be installed via **epm** - in particular:

```elvish
use epm

epm:install github.com/giancosta86/astral-bridge
```

Even better, if you have [epm-plus](https://github.com/giancosta86/epm-plus), you can run:

```elvish
epm:install github.com/giancosta86/astral-bridge@v1
```

or any other specific Git reference.

## Usage

### nvm wrapper

The `nvm` command for Bash is transparently wrapped by the `nvm` function in the `nvm` module; in particular, you can access it by adding the following lines to your `rc.elv` file:

```elvish
use github.com/giancosta86/astral-bridge/v1/nvm

# This makes the `nvm` command available
var nvm~ = $nvm:nvm~
```

Optionally, you can add these lines to fully support a _per-directory NodeJS version_ via **nvm**:

```elvish
# This ensures that the NodeJS version is always the one requested by the .nvmrc file or the `engines/node` field in package.json.
set after-chdir = (conj $after-chdir $nvm:after-chdir~)

# This ensures that the cd-hook is called when opening the shell, too.
$nvm:after-chdir~ $pwd
```

### Detecting the requested NodeJS version

The `version/requested` module provides utilities for detecting the _requested NodeJS version_; it is mostly used by the **nvm** wrapper, but feel free to consult the [module](version/requested.elv) for details about its functions.

## Further references

- [Elvish](https://elv.sh/)

- [NodeJS](https://nodejs.org/en) ecosystem.
