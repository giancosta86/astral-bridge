use os
use ../nvm/wrapper

var expected-version = v21.7.3

var alternative-version = v16.14.2

fn -pre-install-versions {
  wrapper:nvm install $expected-version
  wrapper:nvm install $alternative-version
}

-pre-install-versions > $os:dev-null