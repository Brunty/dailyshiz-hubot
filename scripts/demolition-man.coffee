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
#   hubot morality show - Shows the current list of naughty words
#   hubot morality add <word> - Adds a new word to the list, but only if the user has the 'morality' role
#
# Author:
#   whitman, jan0sch
#
# Modifications:
#   alex-wells

module.exports = (robot) ->

  words = robot.brain.get('naughtyWordsList') or [
    'arse',
    'ass',
    'asshole',
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
    'douchecanoe',
    'fuck',
    'fucked',
    'fucking',
    'fucknugget',
    'goddam',
    'goddamn',
    'piss',
    'shit',
    'shitcunt',
    'twat',
    'wank'
  ]
  regex = new RegExp('(?:^|\\s)(' + words.join('|') + ')(?:\\b|$)', 'ig');

  robot.hear regex, (msg) ->
    username = msg.message.user.name
    users = robot.brain.usersForFuzzyName(username)
    if users.length is 1
      user = users[0]

      fined = msg.match.length or 1

      user_credits = user.morality_credits * 1 or 0
      user.morality_credits = user_credits + fined

    response = "#{username}, you have been fined #{fined} "
    if fined != 1
      response += "credits "
    else
      response += "credit "
    response += "for a violation of the verbal morality statute."

    msg.send response

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

  robot.respond /morality add ?(.*)/i, (msg) ->
    naughty = msg.match[1].trim()
    response = ""

    if robot.auth.hasRole(msg.envelope.user,"morality")
      if naughty not in words
        #do adding to the list
        response += "'#{naughty}' added to the naughty list"
        words.push(naughty)
        robot.brain.set('naughtyWordsList',words)	# make sure the list is persisted!

        # update the regex to include the new word
        regex = new RegExp('(?:^|\\s)(' + words.join('|') + ')(?:\\b|$)', 'ig');
      else
        response += "'#{naughty}' is already on the naughty list"
    else
      response += "I'm sorry, only the morality police can add new naughties to the list"

    msg.send response

  robot.respond /morality show/i, (msg) ->
    response = ""

    if robot.auth.hasRole(msg.envelope.user,"morality")
      response += "The naughty words are:\n*#{words.join('*, *')}*."
    else
      response += "You're not allowed to know what the restricted words are"

    msg.send response

