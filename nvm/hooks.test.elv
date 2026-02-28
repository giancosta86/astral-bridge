use os
use path
use ../tests/shared
use ./hooks
use ./wrapper

var nvm~ = $wrapper:nvm~

fn expect-main-version {
  nvm current |
    should-be $shared:main-version

  put $paths |
    should-contain $shared:main-path-entry

  put $paths |
    should-not-contain $shared:alternative-path-entry

  node --version |
    should-be $shared:main-version
}

>> 'nvm' {
  >> 'hooks' {
    >> 'after-chdir' {
      >> 'when version is requested via .nvmrc file in ancestor directory' {
        nvm use $shared:alternative-version

        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          echo $shared:main-version > .nvmrc

          var nested-dir = (path:join alpha beta gamma)

          os:mkdir-all $nested-dir

          hooks:-use-requested-node-version $nested-dir

          expect-main-version
        }
      }

      >> 'when version is requested via package.json in ancestor directory' {
        nvm use $shared:alternative-version

        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          put [
            &engines=[
              &node=$shared:main-version[1..]
            ]
          ] |
            to-json > package.json

          var nested-dir = (path:join alpha beta gamma)

          os:mkdir-all $nested-dir

          hooks:-use-requested-node-version $nested-dir

          expect-main-version
        }
      }

      >> 'registration' {
        >> 'should run the hook on the current directory' {
          nvm use $shared:alternative-version

          fs:with-temp-dir { |temp-dir|
            cd $temp-dir

            echo $shared:main-version > .nvmrc

            var previous-after-chdir = $after-chdir

            try {
              hooks:register-after-chdir

              expect-main-version
            } finally {
              set after-chdir = $previous-after-chdir
            }
          }
        }
      }
    }
  }
}