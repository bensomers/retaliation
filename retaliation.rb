# Retaliation.rb
# Uses the Launcher API for the DreamCheeky OICW Missile Launcher
# Integrates with TeamCity to fire missiles at my coworkers
# Example script! This one is pretty fancy, with support for multiple
# missile launchers (to improve coverage area).

require 'curl'
require 'nokogiri'
require './launcher'

class Retaliation

  API_KEY="YOUR API KEY HERE"
  PROJECTS=%w(YOUR CI PROJECTS HERE)
  URL= "YOUR CI SEVER ADDRESS HERE"
  # targeting data is a hash of teamcity usernames => aiming instructions
  # launchers are tracked by usb device number
  TARGETING_DATA =  { 'coworker #1' => { :launcher => "6", :coordinates => [['right', 3], ['up', 0.5]] },
                      'coworker #2' => { :launcher => "6", :coordinates => [['right', 1], ['down', 0.3]] },
                      'coworker #3' => { :launcher => "8", :coordinates => [['right', 2], ['up', 1], ['down', 0.3]] },
                    }

  attr_accessor :missiles, :launchers

  def initialize
    @missiles = 4
    @launchers = identify_launchers
  end

  def identify_launchers
    launchers = Launcher.find
    @launchers = launchers.inject({}) { |hash, launcher| hash[launcher.device.devnum.to_s] = launcher; hash }
  rescue
    retry
  end

  # We have a custom webservice that checks for potential build-breakers, and
  # reports them in XML as 'turkeys'
  def check_teamcity
    c = Curl::Easy.perform(URL.gsub('API_KEY', API_KEY).gsub('PROJECT', PROJECTS.first))
    xml = Nokogiri::XML(c.body_str)
    turkeys = xml.xpath('//project//turkeys//turkey').map { |turkey_node| turkey_node.text }
    turkeys.shuffle.each { |target| attack(target) if @missiles > 0 }
  end

  def attack(target)
    if launcher = TARGETING_DATA[target][:launcher] and coordinates = TARGETING_DATA[target][:coordinates]
      puts "Attacking target #{target}"
      @launchers[launcher].zero
      @launchers[launcher].script(coordinates)
      @launchers[launcher].fire
    end
    puts "Could not find target #{target}"
    @missiles -= 1
  end
end

