use os
use ../tests/shared
use ./wrapper

var nvm~ = $wrapper:nvm~

>> 'nvm' {
  >> 'wrapper command' {
    >> 'installing a NodeJS version' {
      nvm use $shared:expected-version

      >> 'should be persistent' {
        nvm current |
          should-be $shared:expected-version
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
        install-and-check $shared:expected-version

        install-and-check $shared:alternative-version
      }
    }
  }
}