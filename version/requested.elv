use os
use path
use re
use str
use github.com/giancosta86/ethereal/v1/lang
use github.com/giancosta86/ethereal/v1/seq

fn -detect-from-nvmrc { |directory|
  var nvmrc-path = (path:join $directory .nvmrc)

  if (not (os:is-regular $nvmrc-path)) {
    put $nil
    return
  }

  slurp < $nvmrc-path |
    str:trim-space (all) |
    seq:empty-to-default
}

fn -detect-from-package-json { |directory|
  var package-path = (path:join $directory package.json)

  if (not (os:is-regular $package-path)) {
    put $nil
    return
  }

  var version-field = (
    from-json < $package-path |
      seq:drill-down (all) engines node &default='' |
      str:trim-space (all) |
      seq:empty-to-default
  )

  if (not $version-field) {
    put $nil
    return
  }

  var matches = [(re:find '\d+(?:\.\d+){0,4}' $version-field)]

  if (seq:is-non-empty $matches) {
    put 'v'$matches[0][text]
  } else {
    put $nil
  }
}

#
# Returns the requested NodeJS version in the given directory, looking for it:
#
# 1. In the .nvmrc file
#
# 2. In the `engines/node` field within package.json
#
# If no source is available, $nil is returned.
#
fn detect-in-directory { |@arguments|
  var directory = (lang:get-single-input $arguments)

  coalesce (
    -detect-from-nvmrc $directory
  ) (
    -detect-from-package-json $directory
  )
}

#
# Looks for a requested NodeJS version, applying the algorithm described for `detect-in-directory`,
# from the given `initial-directory` up to the root directory, stopping as soon as a requested version
# is found or the root directory has been scanned.
#
# Returns either the requested version or $nil.
#
fn detect-recursively { |initial-directory|
  var current-directory = (path:abs $initial-directory)

  while $true {
    var version = (detect-in-directory $current-directory)

    if $version {
      put $version
      return
    }

    var parent-directory = (path:dir $current-directory)

    if (eq $parent-directory $current-directory) {
      put $nil
      return
    }

    set current-directory = $parent-directory
  }
}