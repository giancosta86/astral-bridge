use path
use ./requested-version

var nvmrc-version = v18.17.1

var package-json-version = v16.14.0

fn write-test-nvmrc {
  echo $nvmrc-version > .nvmrc
}

fn write-test-package-json {
  var version-for-json = $package-json-version[1..]

  put [
    &engines=[
      &node='>='$version-for-json' <90'
    ]
  ] |
    to-json > package.json
}

>> 'NodeJS' {
  >> 'retrieving the requested version' {
    >> 'from a directory containing only .nvmrc' {
      fs:within-temp-dir {
        write-test-nvmrc

        requested-version:detect-in-directory . |
          should-be $nvmrc-version
      }
    }

    >> 'from a directory containing only package.json field' {
      fs:within-temp-dir {
        write-test-package-json

        requested-version:detect-in-directory . |
          should-be $package-json-version
      }
    }

    >> 'from a directory containing both .nvmrc and package.json field' {
      fs:within-temp-dir {
        write-test-nvmrc
        write-test-package-json

        requested-version:detect-in-directory . |
          should-be $nvmrc-version
      }
    }

    >> 'from a directory not directly containing such information' {
      >> 'when an ancestor directory contains .nvmrc' {
        fs:within-temp-dir {
          write-test-nvmrc

          path:join A B C D |
            fs:mkcd

          requested-version:detect-in-directory . |
            should-be $nil

          requested-version:detect-recursively . |
            should-be $nvmrc-version
        }
      }

      >> 'when an ancestor directory contains only package.json field' {
        fs:within-temp-dir {
          write-test-package-json

          path:join A B C D |
            fs:mkcd

          requested-version:detect-in-directory . |
            should-be $nil

          requested-version:detect-recursively . |
            should-be $package-json-version
        }
      }

      >> 'when an ancestor directory contains both .nvmrc and package.json field' {
        fs:within-temp-dir {
          write-test-nvmrc
          write-test-package-json

          path:join A B C D |
            fs:mkcd

          requested-version:detect-in-directory . |
            should-be $nil

          requested-version:detect-recursively . |
            should-be $nvmrc-version
        }
      }
    }
  }
}