use path
use ../tests/shared
use ./files
use ./paths
use ./wrapper

var nvm~ = $wrapper:nvm~

>> 'nvm' {
  >> 'filtering nvm-downloaded software out of PATH' {
    all [
      alpha
      (paths:get-entry-for-node v29.0.2)
      beta
      (paths:get-entry-for-node v16.4)
      gamma
      delta
      (paths:get-entry-for-node v7.4.3)
      epsilon
    ] |
      paths:filter-out-downloads |
      should-emit [
        alpha
        beta
        gamma
        delta
        epsilon
      ]
  }

  >> 'retrieving the path entry for a NodeJS version' {
    var test-version = v20.5.6

    var test-path = (paths:get-entry-for-node $test-version)

    >> 'should return the expected path' {
      put $test-path |
        should-be (path:join $files:node-download-root $test-version bin)
    }

    >> 'should return an absolute path' {
      path:is-abs $test-path |
        should-be $true
    }
  }

  >> 'ensuring the `nvm current` is in path' {
    fn use-and-ensure { |node-version|
      nvm use $node-version

      paths:ensure-current

      var expected-path = (paths:get-entry-for-node $node-version)

      put $paths |
        should-contain $expected-path
    }

    use-and-ensure $shared:main-version

    use-and-ensure $shared:alternative-version
  }
}