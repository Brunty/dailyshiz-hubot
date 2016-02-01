# Description:
#   Posting too frequently? You might be suffering from RAEG
#
# Dependencies:
#   hubot-auth  for resetting counts and modifying the RAEG interval
#
# Configuration:
#   None
#
# Commands:
#   hubot rage stats - Show statistics on the saltiness of users
#   hubot rage list - Shows who has the highest sodium content
#   hubot rage interval <time> - shows/sets the current interval to consider someone ragey
#   hubot rage posts <count> - shows/sets the number of posts that will trigger someone as ragey within <interval>
#
# Author:
#   alex-wells
#

class rageOmeter
  @robot = null

  # start off the rageOmeter
  constructor: (@robot) ->
    @robot.brain.data.rageOmeter or= {}
    @robot.brain.data.rageOmeter.interval or= 30000 # default to 30 seconds (counted in ms!)
    @robot.brain.data.rageOmeter.posts    or= 5  # default to 5 posts
    
  # adjust or show the interval:
  doInterval: (msg) ->
    # get the new interval or replace it with the current
    new_int = msg.match[1] *1000 or 0
    interval = @robot.brain.data.rageOmeter.interval
    
    response = ''
    if new_int != interval && new_int > 0
      response += "Setting rage interval to #{new_int/1000}s"
      @robot.brain.data.rageOmeter.interval = new_int
    else
      response += "Current rage interval is set to #{interval/1000}s"
      
    msg.send response
    
  # adjust or show the post count
  doPosts: (msg) ->
    # get the new post count, or use the current value
    new_posts = msg.match[1] * 1 or 0
    posts = @robot.brain.data.rageOmeter.posts
    
    response = ''
    if new_posts != posts && new_posts > 0
      response += "Setting number of posts to #{new_posts}"
      @robot.brain.data.rageOmeter.posts = new_posts
    else
      response += "Current number of posts is set to #{posts}"
      
    msg.send response
    
  # work out if a user is salty based on how quickly they're posting
  detectSalt: (msg) ->
    username = msg.message.user.name   
    users = @robot.brain.usersForFuzzyName(username)
    if users.length is 1
      user = users[0]
      now = new Date()
      
      # are we already tracking the RAEG of this user?
      user.rage       or= {}
      user.rage.last  or= now
      user.rage.posts or= 1
      
      # check what if we're already timing this person for RAEG
      last = new Date(user.rage.last)
      diff = (now.getTime() - last.getTime())
      interval = @robot.brain.data.rageOmeter.interval
      posts = @robot.brain.data.rageOmeter.posts
      
      # dump the user object:
      #@robot.logger.info("detectSalt():\n"+JSON.stringify(user)+"\ndiff: #{diff}\tinterval: #{interval}")
      
      if ( diff >= interval )
        # it's been too long; reset the post counter:
        user.rage.posts = 1
        user.rage.last = null
      else
        # increment the count, and update the time of last post
        user.rage.posts += 1
        user.rage.last = now
        
        # have we reached the threshold?
        if user.rage.posts == posts
          user.rage.posts = 0   # reset the counter
      
          #give them some more credits
          user_credits = user.rage.credits * 1 or 0
          user.rage.credits = user_credits + 1

          response = "#{username}, you seem to be suffering from RAEG and have been allocated 1 rage point; have you considered a time out?"
    
          msg.send response
      
  # show who is the most salty:
  # robot.respond /rage stats/i, (msg) ->
  stats: (msg) ->
    score = []
    total = 0
    response = ""

    for own key, user of @robot.brain.users()
      score.push({ name: user.name, score: user.rage.credits }) if user.rage.credits
      total = total + user.rage.credits if user.rage.credits

    score.sort (a, b) ->
      return b.score - a.score

    response += "There have been a total of #{total} RAEG credits issued."
    response += "\nThe saltiest person is #{score[0].name}" if total > 0
    response += "\nThe least salty person is #{score[score.length-1].name}" if score.length > 1
    response += "\nOn average a person has been ragey #{total/score.length} times" if score.length > 1

    msg.send response

  # shows the rage list
  # robot.respond /rage list/i, (msg) ->
  list: (msg) ->
    score = []
    response = ""

    for own key, user of @robot.brain.users()
      score.push({ name: user.name, score: user.rage.credits }) if user.rage.credits

    score.sort (a, b) ->
      return b.score - a.score

    response += "The saltiest people are:\n" if score.length >= 1

    for own key, user of score
      response += "\n#{user.name}: #{user.score} points"

    msg.send response

    
module.exports = (robot) ->
  # set everything up
  robot.rageOmeter = new rageOmeter(robot)

  robot.respond "/rage stats/i", robot.rageOmeter.stats
  robot.respond "/rage list/i",  robot.rageOmeter.list
  robot.respond "/rage interval ?(.*)/i", robot.rageOmeter.doInterval
  robot.respond "/rage posts ?(.*)/i", robot.rageOmeter.doPosts

  regex = new RegExp('(\\S)','ig');
  robot.hear regex, robot.rageOmeter.detectSalt
  