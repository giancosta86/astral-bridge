use os
use str
use github.com/giancosta86/ethereal/v1/command
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/map
use github.com/giancosta86/ethereal/v1/seq

fn -parse-from-package-json { |@arguments|
  var package-json = (lang:get-single-input $arguments)

  var root-package-manager = (
    seq:drill-down $package-json packageManager
  )

  if $root-package-manager {
    str:split @ $root-package-manager | take 1
    return
  }

  var dev-engines-package-manager-name = (
    seq:drill-down $package-json devEngines packageManager name
  )

  if $dev-engines-package-manager-name {
    put $dev-engines-package-manager-name
    return
  }

  put $nil
}

#
# Detects the package manager requested in the current directory, returning the command itself, or $nil if none could be detected.
#
# The detection algorithm works as follows:
#
# 1. If one of the supported fields (`packageManager` or `devEngines/packageManager/name`) is declared in package.json, return the package name.
#
# 2. Otherwise, check the existence of one of the main lockfiles - returning the corresponding package manager command.
#
# 3. Finally, if nothing else worked, $nil is returned.
#
var detect~ = (
  var package-managers-by-lockfile = [
    &package-lock.json=npm
    &yarn.lock=yarn
    &pnpm-lock.yaml=pnpm
  ]

  fn actual-detect {
    var parsed-package-manager = (
      from-json < package.json |
        -parse-from-package-json
    )

    if $parsed-package-manager {
      put $parsed-package-manager
      return
    }

    var lockfile-found = $false

    map:iterate $package-managers-by-lockfile { |lockfile package-manager|
      if (os:is-regular $lockfile) {
        put $package-manager
        set lockfile-found = $true
        break
      }
    }

    if (not $lockfile-found) {
      put $nil
    }
  }

  put $actual-detect~
)

#
# Runs the given command using the best version for the requested package manager in the current directory:
#
# 1. If `&ensure-installed` is enabled and `corepack` is available as a command, execute `corepack install`, to ensure the requested package manager version is available.
#
# 2. Use the `detect` function to detect the command of the package manager, defaulting to `npm`
#
# 3. Run the package manager, forwarding all the arguments.
#
fn exec { |&ensure-installed=$true @arguments|
  if (and $ensure-installed (has-external corepack)) {
    command:silence {
      corepack install
    }
  }

  var command = (
    detect |
      coalesce (all) npm
  )

  (external $command) $@arguments
}