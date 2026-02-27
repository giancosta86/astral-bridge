use path
use ../tests/shared
use ./files
use ./paths
use ./wrapper

var nvm~ = $wrapper:nvm~

fn use-and-ensure { |node-version|
  nvm use $node-version

  paths:ensure-current-node

  var expected-path = (paths:get-entry-for $node-version)

  put $paths |
    should-contain $expected-path
}

>> 'nvm' {
  >> 'filtering downloaded NodeJS bin directories out of PATH' {
    all [
      alpha
      (paths:get-entry-for v29.0.2)
      beta
      (paths:get-entry-for v16.4)
      gamma
      delta
      (paths:get-entry-for v7.4.3)
      epsilon
    ] |
      paths:filter-out-nvm-nodes |
      should-emit [
        alpha
        beta
        gamma
        delta
        epsilon
      ]
  }

  >> 'retrieving the path of a NodeJS version' {
    var test-version = v20.5.6

    var test-path = (paths:get-entry-for $test-version)

    >> 'should be the expected path' {
      put $test-path |
        should-be (paths:get-entry-for $test-version)
    }

    >> 'should be an absolute path' {
      path:is-abs $test-path |
        should-be $true
    }
  }

  >> 'ensuring current NodeJS is in path' {
    use-and-ensure $shared:main-version

    use-and-ensure $shared:alternative-version
  }
}