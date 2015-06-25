# Description:
#   Our hear items for fun and games.
#
module.exports = (robot) ->

  robot.hear /baby.*monkey/i, (res) ->
    res.send "https://www.youtube.com/watch?v=5_sfnQDr1-o"

  robot.hear /badger/i, (res) ->
    res.send "Badgers? BADGERS? WE DON'T NEED NO STINKIN BADGERS"

  robot.hear /I like pie/i, (res) ->
    res.emote "makes a freshly baked pie"
