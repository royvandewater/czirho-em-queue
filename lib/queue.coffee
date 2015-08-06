debug = require('debug')('czirho:bus')

class Queue
  constructor: (options={}) ->
    {@insertPort, @corePorts} = options

  run: =>
    debug "Started queue listening for jobs on: #{@insertPort}, putting jobs in #{@corePorts}"

module.exports = Queue
