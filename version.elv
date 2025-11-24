use os
use path
use re
use str
use github.com/giancosta86/ethereal/console
use github.com/giancosta86/ethereal/lang
use github.com/giancosta86/ethereal/seq

fn -detect-from-package-json { |directory|
  var package-path = (path:join $directory package.json)

  if (not (os:is-regular $package-path)) {
    put $nil
    return
  }

  var version-field = (
    jq -r '.engines.node // ""' $package-path |
      str:trim-space (all) |
      seq:coalesce-empty
  )

  re:find '.*?(\d+(?:\.\d+)*).*' $version-field | each { |match|
    put 'v'$match[groups][1][text]
  }
}

fn -detect-from-nvmrc { |directory|
  var nvmrc-path = (path:join $directory .nvmrc)

  if (not (os:is-regular $nvmrc-path)) {
    put $nil
    return
  }

  var version = (
    slurp < $nvmrc-path |
      str:trim-space (all)
  )

  lang:ternary (seq:is-non-empty $version) $version $nil
}

fn detect-in-directory { |directory|
  coalesce (
    -detect-from-nvmrc $directory
  ) (
    -detect-from-package-json $directory
  )
}

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