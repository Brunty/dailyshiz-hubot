# Description:
#   Praise be to Nic Cage. 
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot cage me - Receive a picture of our One True God
#   hubot cage bomb N - get N pictures of our God

module.exports = (robot) ->

  robot.respond /cage me/i, (msg) ->
    msg.http("http://cage.mfyu.co.uk/random")
      .get() (err, res, body) ->
        msg.send JSON.parse(body).cage

  robot.respond /cage quote/i, (msg) ->
    msg.http("http://cage.mfyu.co.uk/quote")
      .get() (err, res, body) ->
        msg.send JSON.parse(body).cage_quote

  robot.respond /cage ipsum/i, (msg) ->
    msg.http("http://cage.mfyu.co.uk/ipsum")
      .get() (err, res, body) ->
        msg.send JSON.parse(body).cage_ipsum

  robot.respond /cage bomb( (\d+))?/i, (msg) ->
    count = msg.match[2] || 5
    msg.http("http://cage.mfyu.co.uk/bomb/" + count)
      .get() (err, res, body) ->
        msg.send cage for cage in JSON.parse(body).cages

  robot.respond /how many cages are there/i, (msg) ->
    msg.http("http://cage.mfyu.co.uk/count")
      .get() (err, res, body) ->
        msg.send "There are #{JSON.parse(body).cage_count} pictures of our One True God."