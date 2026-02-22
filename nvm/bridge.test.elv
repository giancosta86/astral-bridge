use os
use ./bridge

var nvm~ = $bridge:nvm~

>> 'nvm' {
  >> 'bridged command' {
    >> 'installing a NodeJS version' {
      var expected-version = v12.3.0

      nvm install $expected-version

      >> 'should be persistent' {
        nvm current |
          should-be $expected-version
      }

      >> 'should make a binary available' {
        nvm which current |
          os:is-regular (all) |
          should-be $true
      }
    }

    >> 'switching NodeJS version' {
      fn install-and-check { |version|
        nvm install $version

        nvm use $version

        nvm current |
          should-be $version
      }

      >> 'should be persistent' {
        install-and-check v12.3.0

        install-and-check v21.7.3
      }
    }
  }
}