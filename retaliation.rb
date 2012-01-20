# Retaliation.rb
# Uses the Launcher API for the DreamCheeky OICW Missile Launcher
# Integrates with TeamCity to fire missiles at my coworkers

require 'retaliation'

class Retaliation
  
  TARGETING_DATA =  { 'bensomers' => [['right', 2]  , ['up', 0.5]],
                      'danluchi'  => [['right', 0.5], ['down', 0.25]]
                    }

  def self.attack(target)
    coordinates = TARGETING_DATA[target]
  end
end

