debug = require('debug')('czirho:bus')

class Bus
  constructor: (options={}) ->
    {@corePorts, @subscribePort} = options

  run: =>
    debug "Started bus listening for messages from: #{@corePorts}, emitting on #{@subscribePort}"


module.exports = Bus
