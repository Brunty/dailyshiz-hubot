# Description:
#   Totally legit commit messages to use
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot commit

module.exports = (robot) ->

  robot.respond /commit/i, (msg) ->
    msg.http("http://whatthecommit.com/index.txt")
    .get() (err, res, body) ->
      msg.send body

