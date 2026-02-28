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

  >> 'ensuring the given NodeJS version is in path' {
    all [
      alpha
      (paths:get-entry-for-node v1.0.0)
      beta
      gamma
      (paths:get-entry-for-node v2.0.0)
      delta
    ] |
      paths:ensure-node-version v7.0.0 |
      should-emit [
        (paths:get-entry-for-node v7.0.0)
        alpha
        beta
        gamma
        delta
      ]
  }
}