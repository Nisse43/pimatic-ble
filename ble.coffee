module.exports = (env) ->
  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  
  noble = require "noble"
  events = require "events"

  class BLEPlugin extends env.plugins.Plugin
    init: (app, @framework, @config) =>
      @debug =  @config.debug
      @devices = []
      @peripheralNames = []
      @discovered = false

      @noble = require "noble"
      setInterval( =>
        if @devices?.length > 0
          if @debug
            env.logger.debug "Scan for devices"
            env.logger.debug @devices
          @noble.startScanning([],true)
      , 10000)

      @noble.on 'discover', (peripheral) =>
        if not @discovered
          @discovered = true
          if (@peripheralNames.indexOf(peripheral.advertisement.localName) >= 0)
            if @debug
              env.logger.debug "Device found "+ peripheral.uuid
            @noble.stopScanning()
            @emit "discover", peripheral
          @discoverd = false

      @noble.on 'stateChange', (state) =>
        if state == 'poweredOn'
          @noble.startScanning([],true)

    registerName: (name) =>
      if @debug
        env.logger.debug "Registering peripheral name "+name
      @peripheralNames.push name

    addOnScan: (uuid) =>
      if @debug
        env.logger.debug "Adding device "+uuid
      @devices.push uuid

    removeFromScan: (uuid) =>
      if @debug
        env.logger.debug "Removing device "+uuid
      @devices.splice @devices.indexOf(uuid), 1

  return new BLEPlugin