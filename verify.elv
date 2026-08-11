use github.com/giancosta86/ethereal/v1/console
use github.com/giancosta86/velvet/v4/velvet velvet
use ./nvm/wrapper
use ./tests/shared

console:section &emoji=📥 'Installing the NodeJS versions used by the tests' {
  wrapper:nvm install --no-progress $shared:main-node-version

  wrapper:nvm install --no-progress $shared:alternative-version
}

velvet:velvet &flawless