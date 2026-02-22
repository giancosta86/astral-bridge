use os
use path
use ./hooks
use ./paths

>> 'nvm' {
  >> 'hooks' {
    >> 'after-chdir' {
      >> 'when no version is requested' {
          tmp paths = (paths:get-without-nodejs)

          fs:with-temp-dir { |temp-dir|
            hooks:after-chdir $temp-dir
          }
        }

      >> 'when version is requested via .nvmrc file' {
        var expected-version = v22.17.1

        fs:with-temp-dir { |temp-dir|
          cd $temp-dir

          echo $expected-version > .nvmrc

          var nested-dir = (path:join alpha beta gamma)

          os:mkdir-all $nested-dir

          hooks:after-chdir $nested-dir

          put $paths |
            should-contain (
              path:join ~ .nvm versions node $expected-version bin |
                path:abs (all)
            )
        }
      }

      >> 'when version is requested via package.json' {
        var expected-version-base = 16.14.2

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

          hooks:after-chdir $nested-dir

          put $paths |
            should-contain (
              path:join ~ .nvm versions node 'v'$expected-version-base bin |
                path:abs (all)
            )
        }
      }
    }
  }
}