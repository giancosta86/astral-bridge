use os
use ../tests/shared
use ./wrapper

var nvm~ = $wrapper:nvm~

>> 'nvm' {
  >> 'wrapper command' {
    >> 'switching NodeJS version' {
      fn use-and-check { |version|
        nvm use $version

        nvm current |
          should-be $version

        var current-nvm-binary = (nvm which current)

        os:is-regular $current-nvm-binary |
          should-be $true

        put $current-nvm-binary |
          should-contain $version
      }

      use-and-check $shared:main-version

      use-and-check $shared:alternative-version
    }
  }
}