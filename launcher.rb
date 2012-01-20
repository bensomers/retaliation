# Heavily based on retaliation.py, a python API for the same product, which comes with Jenkins integration
# available at https://github.com/codedance/Retaliation
# This version's in Ruby, though, and its TeamCity integration will come separately.

require 'usb'

class Launcher
  VENDOR_ID = 0x2123 # 8483
  PRODUCT_ID = 0x1010 # 4112
  REQUEST_TYPE = 0x21 # 33
  REQUEST = 0x09 # 9
  PAYLOAD_START = 0x02 # 2
  
  DOWN    = 0x01
  UP      = 0x02
  LEFT    = 0x04
  RIGHT   = 0x08
  FIRE    = 0x10
  STOP    = 0x20

  TARGETING_DATA =  { 'bensomers' => [['right', 2]  , ['up', 0.5]],
                      'danluchi'  => [['right', 0.5], ['down', 0.25]]
                    }

  attr_accessor :device, :handle

  def initialize(device)
    @device = device
    @handle ||= device.open
  end

  def self.find
    launchers = USB.devices.select { |d| d.product && d.product.match(/USB\ Missile\ Launcher/) }.map { |d| Launcher.new(d) }
    launchers.first if launchers.count == 1
  end

  # Takes a command name and a value
  # Value is either seconds (for sleep or move commands),
  #   or number of missiles to fire
  def command(command, value = nil)
    value ||= 7 # long enough to turn the launcher completely in one direction
    command.downcase!
    case command
    when 'right', 'left', 'down', 'up'
      motion = Launcher.const_get(command.upcase)
      send_move(motion, value)
    when 'zero', 'park', 'reset'
      # Move to bottom-left reference point
      send_move(DOWN, 2)
      send_move(LEFT, 7)
    when 'pause', 'sleep'
      sleep(value)
    when 'barrage', 'salvo', 'volley', 'broadside', 'bombard', 'shell', 'shower', 'suppress', 'fusillade'
      send_fire(4)
    when 'fire', 'shoot', 'launch', 'blast'
      # If no value, or value too high, fire 1 missile
      value = 1 unless value && (1..4).include?(value)
      send_fire(value)
    when 'target', 'aim'
      send_aim(value)
    else
      raise("Unknown command: #{command}")
    end
  end

  # Takes an array of two-element command-value arguments
  # Runs them all in sequence
  def script(commands)
    commands.each do |instructions|
      send_stored_command(instructions)
    end
  end

  private 

  # Have to send the command in a USB standard format
  # Includes the PAYLOAD_START, and the command itself as an 8-byte unsigned char sequence
  def send_cmd(cmd)
    payload = [PAYLOAD_START, cmd, 0, 0, 0, 0, 0, 0]
    @handle.usb_control_msg(REQUEST_TYPE, REQUEST, 0, 0, payload.pack('CCCCCCCC'), 0)
  end

  def send_fire(missile_count)
    sleep(0.5)
    (1..missile_count).each do
      send_cmd(FIRE)
      sleep(4.5)
    end
  end

  def send_move(cmd, duration)
    send_cmd(cmd)
    sleep(duration)
    send_cmd(STOP)
  end

  def send_aim(target)
    command('zero')
    coordinates = TARGETING_DATA[target]
    script(coordinates) if coordinates
  end

  def send_stored_command(instructions)
    command(instructions.first, instructions.last)
  end

  def method_missing(method, *arguments, &block)
    command(method.to_s, arguments.first)
  end

end
