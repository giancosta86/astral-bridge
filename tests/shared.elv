use path
use ../nvm/files

var main-node-version = v26.2.0
var main-npm-version = 11.13.0

var main-node-path-entry = (
  path:join $files:node-download-root $main-node-version bin
)

var alternative-version = v16.14.2

var alternative-path-entry = (
  path:join $files:node-download-root $alternative-version bin
)
