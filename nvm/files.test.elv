use path
use ./files

>> 'nvm' {
  >> 'files' {
    >> 'testing for downloaded directory' {
      >> 'when it is actually a downloaded path' {
        path:join $files:node-download-root v20.15.1 |
          files:is-not-downloaded |
          should-be $false
      }

      >> 'when it is not a NodeJS path' {
        files:is-not-downloaded / |
          should-be $true
      }
    }
  }
}