debug = require('debug')('czirho:bus')

class Bus
  constructor: (options={}) ->
    {@port} = options

  run: =>
    debug "Started bus on port: #{@port}"


module.exports = Bus
