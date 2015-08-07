debug = require('debug')('czirho:adapter')
_ = require 'lodash'
uuid = require 'uuid'
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
    id    = uuid.v1()
    debug "sendJob", "sending to: #{queue.port} with id: #{id}"
    queue.socket.send JSON.stringify ['sum', [1, 1], id]

  _createConnectedQueue: (port) =>
    socket = zmq.socket 'push'
    socket.connect "tcp://127.0.0.1:#{port}"

    return { port: port, socket: socket }

module.exports = Adapter
