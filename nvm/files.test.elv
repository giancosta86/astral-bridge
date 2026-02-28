use path
use ./files

>> 'nvm' {
  >> 'files' {
    >> 'testing for download directory' {
      >> 'when a downloaded path is passed' {
        path:join $files:node-download-root v20.15.1 |
          files:is-downloaded |
          should-be $true
      }

      >> 'when a non-downloaded path is passed' {
        files:is-downloaded / |
          should-be $false
      }
    }
  }
}