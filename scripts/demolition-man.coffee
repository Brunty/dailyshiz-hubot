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
#   hubot morality stats - Show statistics on the immorality of the users.
#   hubot morality list - Show the list of immoral people.
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
  regex = new RegExp('(' + words.join('|') + ')', 'i');

  robot.hear regex, (msg) ->
    username = msg.message.user.name
    users = robot.brain.usersForFuzzyName(username)
    if users.length is 1
      user = users[0]

      user_credits = user.morality_credits * 1 or 0
      user.morality_credits = user_credits + 1

    msg.send "#{username}, you have been fined one credit for a violation of the verbal morality statute."

  robot.respond /morality stats/i, (msg) ->
    score = []
    total = 0
    response = ""

    for own key, user of robot.brain.users()
      score.push({ name: user.name, score: user.morality_credits }) if user.morality_credits
      total = total + user.morality_credits if user.morality_credits

    score.sort (a, b) ->
      return b.score - a.score

    response += "There have been a total of #{total} morality credits issued."
    response += "\nThe most immoral person is #{score[0].name}" if total > 0
    response += "\nThe least immoral person is #{score[score.length-1].name}" if score.length > 1
    response += "\nOn average an immoral person has been immoral #{total/score.length} times" if score.length > 1

    msg.send response

  robot.respond /morality list/i, (msg) ->
    score = []
    response = ""

    for own key, user of robot.brain.users()
      score.push({ name: user.name, score: user.morality_credits }) if user.morality_credits

    score.sort (a, b) ->
      return b.score - a.score

    response += "The immoral people are:\n" if score.length >= 1

    for own key, user of score
      response += "\n#{user.name}: #{user.score} credits"

    response += "\n\nIf your name is not mentioned you should conisder yourself an upstanding citizen."

    msg.send response
