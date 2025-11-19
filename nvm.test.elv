use os
use path
use github.com/giancosta86/ethereal/console
use github.com/giancosta86/ethereal/fs
use ./nvm

>> 'In nvm module' {
  >> 'installing a NodeJS version' {
    >> 'should be persistent' {
      nvm:nvm install v12.3.0

      nvm:nvm current |
        should-be v12.3.0
    }

    >> 'should make a binary available' {
      nvm:nvm which current |
        os:is-regular (all) |
        should-be $true
    }
  }

  >> 'switching NodeJS version' {
    >> 'should be persistent' {
      nvm:nvm use v12.3.0

      nvm:nvm current |
        should-be v12.3.0

      nvm:nvm install v21.7.3

      nvm:nvm current |
        should-be v21.7.3
    }
  }

  >> 'ensuring current NodeJS is in path' {
    nvm:nvm use v21.7.3

    nvm:ensure-current-node-in-path

    has-value $paths (
      path:join ~ .nvm versions node v21.7.3 bin |
        path:abs (all)
    ) |
      should-be $true
  }

  >> 'after-chdir-hook' {
    >> 'when no version is requested' {
      var paths-without-downloaded-nodejs = (nvm:-get-paths-without-downloaded-nodejs)
      tmp paths = $paths-without-downloaded-nodejs

      fs:with-temp-dir { |temp-dir|
        nvm:after-chdir-hook $temp-dir
      }
    }

    >> 'when version is requested via .nvmrc file' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        echo v22.17.1 > .nvmrc

        var nested-dir = (path:join alpha beta gamma)

        os:mkdir-all $nested-dir

        nvm:after-chdir-hook $nested-dir

        has-value $paths (
          path:join ~ .nvm versions node v22.17.1 bin |
            path:abs (all)
        ) |
          should-be $true
      }
    }

    >> 'when version is requested via package.json' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        echo '{ "engines": { "node": "16.14.2" }}' > package.json

        var nested-dir = (path:join alpha beta gamma)

        os:mkdir-all $nested-dir

        nvm:after-chdir-hook $nested-dir

        has-value $paths (
          path:join ~ .nvm versions node v16.14.2 bin |
            path:abs (all)
        ) |
          should-be $true
      }
    }
  }
}
