debug = require('debug')('czirho:bus')
_ = require 'lodash'
zmq = require 'zmq'

class Bus
  constructor: (options={}) ->
    {@insertPort, @subscribePort} = options
    @initialize()

  initialize: =>
    @inbox = zmq.socket 'rep'
    @inbox.on 'message', @onMessage
    @outbox = zmq.socket 'pub'

  run: =>
    @inbox.bindSync "tcp://127.0.0.1:#{@insertPort}"
    @outbox.bindSync "tcp://127.0.0.1:#{@subscribePort}"
    debug "Started bus listening for messages on: #{@insertPort}, emitting on #{@subscribePort}"

    # Uncomment to create random queue failures
    randomDelay = _.random 0, 60
    debug 'delay', randomDelay
    _.delay @downTime, 1000 * randomDelay

  downTime: =>
    randomDelay = _.random 0, 5
    console.log "downtime for #{randomDelay}s"
    @inbox.close()
    @outbox.close()
    _.delay @restart, 1000 * randomDelay

  restart: =>
    console.log "coming back up"
    @initialize()
    @run()

  onMessage: (id, messageStr) =>
    debug 'onMessage', id.toString(), messageStr.toString(), @insertPort
    @inbox.send id
    @outbox.send [id.toString(), messageStr.toString()]

module.exports = Bus
