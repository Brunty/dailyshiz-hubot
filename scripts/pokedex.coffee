# Description
#   A hubot script that catches them all
#
# Configuration:
#
# Commands:
#   hubot pokedex 15 - <gives pokedex stats on Beedrill (pokemon with id of 15)>
#
# Author:
#   Chase Coney[chase.coney@chaseconey.com]

fetchPokemon = (msg, uri) ->
  msg.http("#{uri}")
    .get() (err, res, body) ->
      results = JSON.parse(body)
      if results.eror
        msg.send "error"
        return

      abilities = gather(results.abilities, 'name')
      moves = gather(results.moves, 'name')
      types = gather(results.types, 'name')
      evolutions = gather(results.evolutions, 'to')

      msg.send "http://pokeapi.co/media/img/#{results.pkdx_id}.png"
      msg.send "Name: #{results.name} [#{types}]\n
        Evolutions: #{evolutions}\n
        Attack: #{results.attack}\n
        Defense: #{results.defense}\n
        Catch rate: #{results.catch_rate}\n
        Abilities: #{abilities}\n
        # of Moves: #{moves.length}\n
        GOTTA CATCH'EM ALL!"

gather = (attr, prop) ->
  str = ''
  for key,value of attr
    str += value[prop] + ' '
  str.trim()

getPokemon = (msg) ->
  poke_id = escape(msg.match[1])

  fetchPokemon(msg, "http://pokeapi.co/api/v1/pokemon/#{poke_id}/")



# retrieves a random pokemon by grabbing the current pokedex, then selecting
# a random entry from it and loading that
getWild = (msg) ->
  msg.http("http://pokeapi.co/api/v1/pokedex/1/")
    .get() (err, res, body) ->
      pokedex = JSON.parse(body)
      if pokedex.eror
        msg.send "no pokemon are in this location"
        return

      msg.send "retrieved pokedex"
      msg.send "#{pokedex}"

      # got our pokedex, find a random entry, then invoke getPokemon
      pokemon = pokedex.pokemon[Math.floor(Math.random() * pokedex.pokemon.length)]
      msg.send "#{pokemon}"

      msg.send "Getting pokemon from http://pokeapi.co/#{pokemon.resource_uri}"

      fetchPokemon(msg, "http://pokeapi.co/#{pokemon.resource_uri}")


module.exports = (robot) ->
  robot.respond /pokedex me (.*)/i, (msg) ->
    getPokemon(msg)

  robot.hear /a wild pokemon appears/i, (msg) ->
    getWild(msg)
