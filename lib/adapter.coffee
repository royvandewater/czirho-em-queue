debug = require('debug')('czirho:adapter')
_ = require 'lodash'
zmq = require 'zmq'

class Adapter
  constructor: (options={}) ->
    {@queuePorts, @busPorts} = options

  run: =>
    debug "Started adapter. Putting jobs in #{@queuePorts}, getting messages from #{@busPorts}"
    @interval = setInterval @sendJob, 1000

  sendJob: =>
    port = _.sample @queuePorts
    debug "sendJob", "sending to: #{port}"
    jobQueue = zmq.socket 'push'
    jobQueue.connect "tcp://127.0.0.1:#{port}"
    jobQueue.send JSON.stringify ['add', 1, 1]

module.exports = Adapter
