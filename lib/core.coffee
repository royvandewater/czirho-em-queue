debug = require('debug')('czirho:core')

class Core
  constructor: (options={}) ->
    {@insertPort, @subscribePort} = options

  run: =>
    debug "Started core listening on: #{@insertPort}, emitting on #{@subscribePort}"


module.exports = Core
