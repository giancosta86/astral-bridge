use path
use ../tests/shared
use ./paths
use ./wrapper

var nvm~ = $wrapper:nvm~

>> 'nvm' {
  >> 'ensuring current NodeJS is in path' {
    nvm use $shared:expected-version

    paths:ensure-current-node

    var expected-path-entry = (
      path:join ~ .nvm versions node $shared:expected-version bin |
        path:abs (all)
    )

    put $paths  |
      should-contain $expected-path-entry
  }
}