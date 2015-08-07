debug = require('debug')('czirho:adapter')
_ = require 'lodash'
zmq = require 'zmq'

class Adapter
  constructor: (options={}) ->
    {@queuePorts, @busPorts} = options
    @queues = []

  run: =>
    debug "Started adapter. Putting jobs in #{@queuePorts}, getting messages from #{@busPorts}"
    @queues = _.map @queuePorts, @_createConnectedQueue
    @interval = setInterval @sendJob, 1000

  sendJob: =>
    queue = _.sample @queues
    debug "sendJob", "sending to: #{queue.port}"
    queue.socket.send JSON.stringify ['add', 1, 1]

  _createConnectedQueue: (port) =>
    socket = zmq.socket 'push'
    socket.connect "tcp://127.0.0.1:#{port}"

    return { port: port, socket: socket }

module.exports = Adapter
