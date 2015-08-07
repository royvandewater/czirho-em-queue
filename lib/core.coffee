debug = require('debug')('czirho:core')
_ = require 'lodash'
zmq = require 'zmq'

VALID_OPERATIONS = ['add']

class Core
  constructor: (options={}) ->
    {@insertPort, @subscribePort} = options
    @jobQueue = zmq.socket 'pull'
    @jobQueue.on 'message', @onMessage

  run: =>
    @jobQueue.bindSync "tcp://127.0.0.1:#{@insertPort}"
    debug "Started core listening on: #{@insertPort}, emitting on #{@subscribePort}"

  onMessage: (messageStr) =>
    debug 'message received', messageStr.toString()

    try
      [operation, args...] = JSON.parse messageStr
    catch
      return debug 'bad JSON, ignoring'

    unless _.contains VALID_OPERATIONS, operation
      return debug 'bad operation, ignoring'

    @[operation](args...)

  add: =>
    debug 'add', arguments
    sum = _.reduce arguments, (total, n) => total + n

module.exports = Core
