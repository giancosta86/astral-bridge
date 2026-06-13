use os
use path
use ../nvm/files
use ../nvm/wrapper

var main-node-version = v21.7.3

var main-node-path-entry = (
  path:join $files:node-download-root $main-node-version bin
)

var alternative-version = v16.14.2

var alternative-path-entry = (
  path:join $files:node-download-root $alternative-version bin
)

fn -pre-install-versions {
  if (not (os:is-dir $main-node-path-entry)) {
    wrapper:nvm install --no-progress $main-node-version
  }

  if (not (os:is-dir $alternative-path-entry)) {
    wrapper:nvm install --no-progress $alternative-version
  }
}

-pre-install-versions > $os:dev-null