debug = require('debug')('czirho:core')

class Core
  constructor: (options={}) ->
    {@port} = options

  run: =>
    debug "Started core on port: #{@port}"


module.exports = Core
