debug = require('debug')('czirho:queue')
_ = require 'lodash'
zmq = require 'zmq'

class Queue
  constructor: (options={}) ->
    {@insertPort, @corePorts} = options
    @initialize()

  initialize: =>
    @pendingRequests = {}
    @jobQueue = zmq.socket 'rep'
    @jobQueue.on 'message', @onMessage

  run: =>
    @jobQueue.bindSync "tcp://127.0.0.1:#{@insertPort}"
    @cores = _.map @corePorts, @_createConnectedCore
    _.each @cores, (core) => core.socket.on 'message', @onReply
    debug "Started queue listening for jobs on: #{@insertPort}, putting jobs in #{@corePorts}"

    # Uncomment to create random queue failures
    randomDelay = _.random 0, 60
    debug 'delay', randomDelay
    _.delay @downTime, 1000 * randomDelay

  downTime: =>
    randomDelay = _.random 0, 5
    console.log "downtime for #{randomDelay}s"
    @jobQueue.close()
    _.delay @restart, 1000 * randomDelay

  restart: =>
    console.log "coming back up"
    @initialize()
    @run()

  onMessage: (message) =>
    messageStr = message.toString()
    debug 'message received', messageStr, @insertPort

    try
      [operation, args, id] = @_parseMessage messageStr
    catch error
      return debug error.message

    @jobQueue.send id
    @sendMessage operation, args, id

  onReply: (idBuffer) =>
    id = idBuffer.toString()

    debug 'onReply', id
    delete @pendingRequests[id]

  sendMessage: (operation, values, id) =>
    @pendingRequests[id] = true

    core = _.sample @cores
    throw new Error('no cores available for work') unless core?
    debug "sendMessage", "sending to: #{core.port} with id: #{id}"
    core.socket.send JSON.stringify [operation, values, id]

    _.delay =>
      return unless @pendingRequests[id]?
      console.warn "Request timed out, trying again"
      @sendMessage operation, values, id
    , 100

  _createConnectedCore: (port) =>
    socket = zmq.socket 'req'
    socket.connect "tcp://127.0.0.1:#{port}"

    return { port: port, socket: socket }

  _parseMessage: (messageStr) =>
    try
      message = JSON.parse messageStr
    catch
      throw new Error 'bad JSON, ignoring'

    return message

module.exports = Queue
