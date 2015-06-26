# Description:
#   BassetMe is the mostest important thing in life
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot basset me - Receive a basset
#   hubot basset bomb N - get N bassets

Flickr = require 'node-flickr'

flickrOptions = {
  api_key: process.env.HUBOT_FLICKR_API_KEY,
  secret: process.env.HUBOT_FLICKR_SECRET
}

flickrSearch = {
  text: 'basset',
  group_id: '35034344814@N01'
}

flickr = new Flickr(flickrOptions)

bassets = undefined

flickr.get 'photos.search', flickrSearch, (err, result) ->
  bassets = result.photos.photo

module.exports = (robot) ->
  robot.respond /basset me/i, (msg) ->
    image = msg.random bassets
    msg.send "https://farm#{image.farm}.staticflickr.com/#{image.server}/#{image.id}_#{image.secret}_c.jpg"
