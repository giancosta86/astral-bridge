use os
use ../nvm/wrapper

var expected-version = v21.7.3

var alternative-version = v16.14.2

fn -pre-install-versions {
  wrapper:nvm install --no-progress  $expected-version
  wrapper:nvm install --no-progress  $alternative-version
}

-pre-install-versions > $os:dev-null