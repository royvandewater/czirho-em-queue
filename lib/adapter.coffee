debug = require('debug')('czirho:adapter')
_ = require 'lodash'
uuid = require 'uuid'
zmq = require 'zmq'

class Adapter
  constructor: (options={}) ->
    {@busPorts, @queuePorts, @interval} = options
    @pendingMessages = {}
    @pendingRequests = {}

  run: =>
    if _.isEmpty @queuePorts
      console.error "Adapter has no queues, cannot send jobs"
      process.exit 1

    console.warn "No buses passed in to adapter, responses will not be received" if _.isEmpty @busPorts
    console.warn "Interval is unset, that's probably a bad idea..." unless @interval?

    @buses = _.map @busPorts, @_createConnectedBus
    _.each @buses, (bus) => bus.socket.on 'message', @onMessage

    @queues = _.map @queuePorts, @_createConnectedQueue
    _.each @queues, (queue) => queue.socket.on 'message', @onReply

    @interval = setInterval @doWork, @interval
    debug "Started adapter. Putting jobs in #{@queuePorts}, getting messages from #{@busPorts}"

  doWork: =>
    values = _.times _.random(1,10), => _.random(1,10)
    @sendMessageForResult 'sum', values

  onMessage: (idBuffer, messageStrBuffer) =>
    id = idBuffer.toString()
    messageStr = messageStrBuffer.toString()

    debug 'onMessage', id, messageStr
    _.each @buses, (bus) => bus.socket.unsubscribe id
    @printMessage id, messageStr

  onReply: (idBuffer) =>
    id = idBuffer.toString()

    debug 'onReply', id
    delete @pendingRequests[id]

  printMessage: (id, message) =>
    values = @pendingMessages[id].values
    valuesStr = values.join ' + '
    console.log "#{valuesStr} = #{message}"
    delete @pendingMessages[id]

  sendMessageForResult: (operation, values) =>
    id    = uuid.v1()

    @pendingMessages[id] = {operation: operation, values: values}

    debug "subscribing to #{id}"
    _.each @buses, (bus) => bus.socket.subscribe id
    @sendMessage operation, values, id

  sendMessage: (operation, values, id) =>
    @pendingRequests[id] = true

    queue = _.sample @queues
    debug "sendMessage", "sending to: #{queue.port} with id: #{id}"
    queue.socket.send JSON.stringify [operation, values, id]
    _.delay =>
      return unless @pendingRequests[id]?
      debug 'Request timed out, trying again'
      @sendMessage operation, values, id
    , 1000

  _createConnectedBus: (port) =>
    socket = zmq.socket 'sub'
    socket.connect "tcp://127.0.0.1:#{port}"

    return { port: port, socket: socket }

  _createConnectedQueue: (port) =>
    socket = zmq.socket 'req'
    socket.connect "tcp://127.0.0.1:#{port}"

    return { port: port, socket: socket }

module.exports = Adapter
