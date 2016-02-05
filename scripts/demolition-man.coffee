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
#   hubot morality remove <word> - Removes a word from the list, but only if the user has the 'morality' role
#
# Author:
#   whitman, jan0sch
#
# Modifications:
#   alex-wells

class moralityList
  @listenerIdx = -1
  @robot = null

  # start off the moralityList
  constructor: (@robot) ->
    # populate the list if it doesn't already exist
    @robot.brain.data.moralityList or= ['arse', 'ass', 'asshole', 'bastard', 'bloody', 'bitch', 'bugger', 'bollocks', 'bullshit', 'cock',
      'crap', 'crapping', 'cunt', 'damn', 'damnit', 'dick', 'douche', 'douchecanoe', 'fuck', 'fucked', 'fucking', 'fucknugget', 'goddam',
      'goddamn', 'piss', 'shit', 'shitcunt', 'twat', 'wank' ] # set the default list here

    #set up all the responders, but only once we've got the list out of redis:
#    @robot.brain.on 'loaded', (data) =>
#      @robot.respond("/morality stats/i", @stats)
#      @robot.respond("/morality list/i", @list)
#      @robot.respond("/morality show/i", @show)
#      @robot.respond("/morality add ?(.*)/i", @addWord)
#      @robot.respond("/morality remove ?(.*)/i", @delWord)
#      @rebuild  # sets up the regex for the current list, ready to fine people!


  # gets the list of words
  words: ->
    @robot.brain.data.moralityList

  # adds a word to the list
  add: (word) ->
    @words().push(word)
#    @robot.logger.debug 'starting rebuild'
    @robot.moralityList.rebuild()

  # removes a word from the list
  del: (word) ->
    index = @words().indexOf(word)
    if index isnt -1
      @words().splice(index, 1)
#      @robot.logger.debug 'starting rebuild'
      @robot.moralityList.rebuild()

  #rebuild the regex and update the listener
  rebuild: () ->
#    @robot.logger.debug 'actually in rebuild()'

    # remove the old listener
    if @robot.moralityList.listenerIdx > -1
      @robot.listeners.splice(@listenerIdx, 1)

    # build the new regex
    regex = new RegExp('(?:^|\\s)(' + @robot.moralityList.words().join('|') + ')(?:\\b|$)', 'ig')

    # add the listener to the robot
    @robot.hear regex, @robot.moralityList.fine
    @listenerIdx = @robot.listeners.length - 1

  # does the actual fining of users
  fine: (msg) ->
    username = msg.message.user.name
    users = @robot.brain.usersForFuzzyName(username)
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

  # displays current statistics
  # robot.respond /morality stats/i, (msg) ->
  stats: (msg) ->
    score = []
    total = 0
    response = ""

    for own key, user of @robot.brain.users()
      score.push({ name: user.name, score: user.morality_credits }) if user.morality_credits
      total = total + user.morality_credits if user.morality_credits

    score.sort (a, b) ->
      return b.score - a.score

    response += "There have been a total of #{total} morality credits issued."
    response += "\nThe most immoral person is #{score[0].name} with #{score[0].score} credits" if total > 0
    response += "\nThe least immoral person is #{score[score.length-1].name} with #{score[score.length-1].score} credits" if score.length > 1
    response += "\nOn average an immoral person has been immoral #{total/score.length} times" if score.length > 1

    msg.send response

  # shows the morality list
  # robot.respond /morality list/i, (msg) ->
  list: (msg) ->
    score = []
    response = ""

    for own key, user of @robot.brain.users()
      score.push({ name: user.name, score: user.morality_credits }) if user.morality_credits

    score.sort (a, b) ->
      return b.score - a.score

    response += "The immoral people are:\n" if score.length >= 1

    for own key, user of score
      response += "\n#{user.name}: #{user.score} credits"

    response += "\n\nIf your name is not mentioned you should conisder yourself an upstanding citizen."

    msg.send response

  # lists the words currently on the list
  # robot.respond /morality show/i, (msg) ->
  show: (msg) ->
    response = ""

    if @robot.auth.hasRole(msg.envelope.user,"morality")
      if @robot.moralityList.words().length == 0
        response += "There are no finable words at this time."
      else
        response += "The finable words are:\n*#{@robot.moralityList.words().join('*, *')}*."
    else
      response += "You're not allowed to know what the finable words are"

    msg.send response

  # adds a new word to the list, rebuilding the regex/listener as we go:
  # robot.respond /morality add ?(.*)/i, (msg) ->
  addWord: (msg) ->
    newSwear = msg.match[1].trim()
    response = ""

    if @robot.auth.hasRole(msg.envelope.user,"morality")
      if newSwear not in @robot.moralityList.words()
        #do adding to the list
        @robot.moralityList.add(newSwear)
        response += "'#{newSwear}' has been added to the finable words list"
      else
        response += "'#{newSwear}' is already on the finable words list"
    else
      response += "I'm sorry, only the morality police can add new words to the list"

    msg.send response

  # removes a word from the list
  # robot.respond /morality remove ?(.*)/i, (msg) ->
  delWord: (msg) ->
    response = ""
    word = msg.match[1].trim()

    # is the user authorised to do so?
    if @robot.auth.hasRole(msg.envelope.user,"morality")
      if word not in @robot.moralityList.words()
        response += "#{word} isn't on the finable words list"
      else
        @robot.moralityList.del(word)
        response += "Removed '#{word}' from the finable words list"
    else
      response += "You're not allowed to remove entries from the finable words list"

    msg.send response

  # set a users credit value
  # /morality set credit ([^\\s]+) ([\\d]{1,4})/i, (msg) ->
  updateCredit: (msg) ->
    response = ""
    user = msg.match[1].trim()
    credit = msg.match[2].trim()

    # is the user authorised to do so?
    if @robot.auth.hasRole(msg.envelope.user,"admin")
      users = @robot.brain.usersForFuzzyName(user)

      if users.length is 1
        user = users[0]

        user.morality_credits = credit
        response += "Set #{user.name}'s credit balance to #{credit}"
      else
        response += "User #{user} has not been found"
    else
      response += "You're not allowed to set the morality credits of a user"

    msg.send response

module.exports = (robot) ->
  # set everything up
  robot.moralityList = new moralityList(robot)

  robot.respond "/morality stats/i", robot.moralityList.stats
  robot.respond "/morality list/i", robot.moralityList.list
  robot.respond "/morality show/i", robot.moralityList.show
  robot.respond "/morality add ([^\\s]+)$/i", robot.moralityList.addWord
  robot.respond "/morality remove ([^\\s]+)$/i", robot.moralityList.delWord
  robot.respond "/morality set credit ([^\\s]+) ([\\d]{1,4})/i", robot.moralityList.updateCredit
  robot.moralityList.rebuild()  # sets up the regex for the current list, ready to fine people!

  #regex = new RegExp('(?:^|\\s)(' + robot.moralityList.words().join('|') + ')(?:\\b|$)', 'ig');
  #robot.hear regex, robot.moralityList.fine
