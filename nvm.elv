use ./nvm/bridge
use ./nvm/hooks
use ./nvm/paths

var nvm~ = $bridge:nvm~
var after-chdir~ = $hooks:after-chdir~
var ensure-current-nodejs~ = $paths:ensure-current-nodejs~