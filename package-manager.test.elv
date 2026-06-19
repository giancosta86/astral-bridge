use ./corepack
use ./nvm
use ./package-manager
use ./tests/shared

>> 'Package manager' {
  nvm:nvm install $shared:main-node-version

  corepack:setup

  >> 'parsing from package.json' {
    >> 'when the root packageManager field is declared' {
      >> 'with name, version and checksum' {
        package-manager:-parse-from-package-json [
          &packageManager=yarn@3.2.3+sha224.953c8233f7a92884eee2de69a1b92d1f2ec1655e66d08071ba9a02fa
        ] |
          should-be yarn
      }

      >> 'with name and checksum' {
        put [
          &packageManager=yarn@3.2.3
        ] |
          package-manager:-parse-from-package-json |
          should-be yarn
      }

      >> 'with just the name' {
        put [
          &packageManager=yarn
        ] |
          package-manager:-parse-from-package-json |
          should-be yarn
      }
    }

    >> 'when the devEngines/packageManager field is declared' {
      package-manager:-parse-from-package-json [
        &devEngines=[
          &packageManager=[
            &name=yarn
            &version=3.2.3
          ]
        ]
      ] |
        should-be yarn
    }

    >> 'when both fields are declared' {
      put [
        &packageManager=pnpm
        &devEngines=[
          &packageManager=[
            &name=yarn
            &version=3.2.3
          ]
        ]
      ] |
        package-manager:-parse-from-package-json |
        should-be pnpm
    }
  }

  >> 'detection' {
    >> 'when declared in package.json' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        put [
          &packageManager=yarn@3.2.3
        ] |
          to-json > package.json

        package-manager:detect |
          should-be yarn
      }
    }

    >> 'when package.json has no related field, but a lockfile is present' {
      all [
        [package-lock.json npm]
        [yarn.lock yarn]
        [pnpm-lock.yaml pnpm]
      ] |
        seq:spread { |lockfile expected-package-manager|
          >> 'for '$lockfile {
            fs:with-temp-dir { |temp-dir|
              cd $temp-dir

              put [&] | to-json > package.json
              fs:touch $lockfile

              package-manager:detect |
                should-be $expected-package-manager
            }
          }
        }
    }

    >> 'when only a lockfile is present' {
      all [
        [package-lock.json npm]
        [yarn.lock yarn]
        [pnpm-lock.yaml pnpm]
      ] |
        seq:spread { |lockfile expected-package-manager|
          >> 'for '$lockfile {
            fs:with-temp-dir { |temp-dir|
              cd $temp-dir

              fs:touch $lockfile

              package-manager:detect |
                should-be $expected-package-manager
            }
          }
        }
    }

    >> 'when no clue is available' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        package-manager:detect |
          should-be $nil
      }
    }
  }

  >> 'running' {
    >> 'when the package manager is declared in package.json' {
      all [
        [yarn 3.2.3]
        [pnpm 11.4.0]
      ] | seq:spread { |name version|
        >> 'for '$name {
          fs:with-temp-dir { |temp-dir|
            cd $temp-dir

            put [
              &packageManager=$name'@'$version
            ] |
              to-json > package.json

            package-manager:exec --version |
              should-match-regex '\b'$version'\b'
          }
        }
      }
    }

    >> 'when package.json is missing' {
      fs:with-temp-dir { |temp-dir|
        cd $temp-dir

        package-manager:exec --version |
          should-be $shared:main-npm-version
      }
    }
  }
}