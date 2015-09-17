# Description:
#   Watch your language!
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#
# Author:
#   whitman, jan0sch

module.exports = (robot) ->

  words = [
    'arse',
    'ass',
    'bastard',
    'bloody',
    'bitch',
    'bugger',
    'bollocks',
    'bullshit',
    'cock',
    'crap',
    'crapping',
    'cunt',
    'damn',
    'damnit',
    'dick',
    'douche',
    'fuck',
    'fucked',
    'fucking',
    'goddam',
    'goddamn',
    'piss',
    'shit',
    'twat',
    'wank'
  ]
  regex = new RegExp('(?:^|\\s)(' + words.join('|') + ')(?:\\s|\\.|\\?|!|$)', 'i');

  robot.hear regex, (msg) ->
    username = msg.message.user.name
    users = robot.brain.usersForFuzzyName(username)
    if users.length is 1
      user = users[0]

      user_credits = user.morality_credits * 1 or 0
      user.morality_credits = user_credits + 1

    msg.send "#{username}, you have been fined one credit for a violation of the verbal morality statute."

  robot.respond /morality credits/i, (msg) ->
    score = []
    total = 0
    response = ""

    for own key, user of robot.brain.users()
      score.push({ name: user.name, score: user.morality_credits }) if user.morality_credits
      total = total + user.morality_credits if user.morality_credits

    score.sort (a, b) ->
      return a.score == b.score ? 0 : +(a.score > b.score) || -1;

    response += "There have been a total of #{total} morality credits issued.\n"
    response += "The most immoral person is #{score[0].name}\n" if total > 0
    response += "The least immoral person is #{score[score.length-1].name}\n" if score.length > 1
    response += "On average an immoral person has been immoral #{total/score.length} times" if score.length > 1

    msg.send response
    
    robot.respond /list sinners/i, (msg) ->
      response = ""
      
      response += "The naughty people are:\n"
      for own key, user of robot.brain.users()
        response += "#{user.name}: #{user.morality_credits} credits\n"

      msg.send response
