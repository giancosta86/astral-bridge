use os
use path
use ../nvm/files
use ../nvm/wrapper

var main-version = v21.7.3

var main-path-entry = (
  path:join $files:download-node-root $main-version bin
)

var alternative-version = v16.14.2

var alternative-path-entry = (
  path:join $files:download-node-root $alternative-version bin
)

fn -pre-install-versions {
  if (not (os:is-dir $main-path-entry)) {
    wrapper:nvm install --no-progress $main-version
  }

  if (not (os:is-dir $alternative-path-entry)) {
    wrapper:nvm install --no-progress $alternative-version
  }
}

-pre-install-versions > $os:dev-null