debug = require('debug')('czirho:queue')
_ = require 'lodash'
zmq = require 'zmq'

class Queue
  constructor: (options={}) ->
    {@insertPort, @corePorts} = options
    @jobQueue = zmq.socket 'pull'
    @jobQueue.on 'message', @onMessage

  run: =>
    @jobQueue.bindSync "tcp://127.0.0.1:#{@insertPort}"
    debug "Started queue listening for jobs on: #{@insertPort}, putting jobs in #{@corePorts}"

  onMessage: (message) =>
    debug 'message received', message.toString()
    @sendJob message

  sendJob: (message) =>
    port = _.sample @corePorts
    debug "sendJob", "sending to: #{port}"
    core = zmq.socket 'push'
    core.connect "tcp://127.0.0.1:#{port}"
    core.send message

module.exports = Queue
