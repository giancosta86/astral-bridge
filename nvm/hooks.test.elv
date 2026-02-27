use os
use path
use ../tests/shared
use ./hooks
use ./paths
use ./wrapper

var nvm~ = $wrapper:nvm~

>> 'nvm' {
  >> 'hooks' {
    >> 'after-chdir' {
      >> 'when no version is requested' {
          tmp paths = (paths:get-without-nodejs)

          fs:with-temp-dir { |temp-dir|
            hooks:-use-requested-nodejs-version $temp-dir
          }
        }

      >> 'when version is requested via .nvmrc file' {
        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          nvm use $shared:alternative-version

          echo $shared:expected-version > .nvmrc

          var nested-dir = (path:join alpha beta gamma)

          os:mkdir-all $nested-dir

          hooks:-use-requested-nodejs-version $nested-dir

          put $paths |
            should-contain (
              path:join ~ .nvm versions node $shared:expected-version bin |
                path:abs (all)
            )
        }
      }

      >> 'when version is requested via package.json' {
        nvm use $shared:alternative-version

        var expected-version-base = $shared:expected-version[1..]

        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          put [
            &engines=[
              &node=$expected-version-base
            ]
          ] |
            to-json > package.json

          var nested-dir = (path:join alpha beta gamma)

          os:mkdir-all $nested-dir

          hooks:-use-requested-nodejs-version $nested-dir

          put $paths |
            should-contain (
              path:join ~ .nvm versions node $shared:expected-version bin |
                path:abs (all)
            )
        }
      }

      >> 'registration' {
        >> 'should run the hook on the current directory' {
          nvm use $shared:alternative-version

          fs:with-temp-dir { |temp-dir|
            cd $temp-dir

            nvm current |
              should-be $shared:alternative-version

            echo $shared:expected-version > .nvmrc

            var previous-after-chdir = $after-chdir

            try {
              hooks:register-after-chdir

              nvm current |
                should-be $shared:expected-version
            } finally {
              set after-chdir = $previous-after-chdir
            }
          }
        }
      }
    }
  }
}