debug = require('debug')('czirho:adapter')

class Adapter
  constructor: (options={}) ->
    {@queuePorts, @busPorts} = options

  run: =>
    debug "Started adapter. Putting jobs in #{@queuePorts}, getting messages from #{@busPorts}"


module.exports = Adapter
