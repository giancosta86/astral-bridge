use path
use ./wrapper
use ./paths

>> 'nvm' {
  >> 'ensuring current NodeJS is in path' {
    var expected-version = v21.7.3

    wrapper:nvm use $expected-version

    paths:ensure-current-nodejs

    has-value $paths (
      path:join ~ .nvm versions node $expected-version bin |
        path:abs (all)
    ) |
      should-be $true
  }
}