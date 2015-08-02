debug = require('debug')('czirho:adapter')

class Adapter
  constructor: (options={}) ->
    {@port} = options

  run: =>
    debug "Started adapter on port: #{@port}"


module.exports = Adapter
