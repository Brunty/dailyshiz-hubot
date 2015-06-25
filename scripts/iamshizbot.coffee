
module.exports = (robot) ->
  robot.hear /^hubot:? (.+)/i, (res) ->
    response = "Sorry, I'm a diva and only respond to #{robot.name}"
    response += " or #{robot.alias}" if robot.alias
    res.reply response
    return
