commander = require 'commander'
_ = require 'lodash'
packageJSON = require './package.json'
Adapter = require './lib/adapter'
Bus = require './lib/bus'
Core = require './lib/core'

class Command
  constructor: ->
    @cores = []
    @buses = []
    @adapters = []

  parseInt: (arg) => parseInt arg

  parseOptions: =>
    @options = commander
      .version packageJSON.version
      .option '-c, --cores <n>',    'number of cores nodes (default: 1)', @parseInt, 1
      .option '-b, --buses <n>',    'number of bus nodes (default: 1)', @parseInt, 1
      .option '-a, --adapters <n>', 'Number of adapter nodes (default: 1)', @parseInt, 1
      .parse process.argv

  run: =>
    @parseOptions()
    @startCores()
    @startBuses()
    @startAdapters()

  randomPort: =>
    _.random 49152, 65535

  startAdapters: =>
    ports = @_generateRandomPorts @options.cores

    _.each ports, (port) =>
      adapter = new Adapter port: port
      adapter.run()
      @adapters.push adapter

  startBuses: =>
    ports = @_generateRandomPorts @options.cores

    _.each ports, (port) =>
      bus = new Bus port: port
      bus.run()
      @buses.push bus

  startCores: =>
    ports = @_generateRandomPorts @options.cores

    _.each ports, (port) =>
      core = new Core port: port
      core.run()
      @cores.push core

  _generateRandomPorts: (n) =>
    _.times n, @randomPort

command = new Command()
command.run()
