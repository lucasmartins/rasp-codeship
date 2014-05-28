require 'json'

class CodeshipBuildStatus
  TOKEN = ENV['CODESHIP_TOKEN']
  PROJECT = ENV['CODESHIP_PROJECT']
  PIN_MAP = {running: 18, broken: 17}

  def self.run!
    raise 'I need both CODESHIP_TOKEN and CODESHIP_PROJECT env var to be set!' unless ENV['CODESHIP_TOKEN'] && ENV['CODESHIP_PROJECT']
    boot_pins
    trap("SIGINT") do
      puts 'Bye bye!'
      pin(:broken,:off) # alert the script is down!
      exit!
    end
    puts 'Starting...'
    while true do
      if build_status==:success
        puts 'Build is good'
        pin(:broken,:off)
        pin(:running,:off)
      else
        if build_status==:testing
          puts 'Building ...'
          pin(:broken,:off)
          pin(:running,:off)
          sleep 0.1
          pin(:running,:on)
        else
          puts 'Build is bad'
          pin(:broken,:on)
          pin(:running,:off)
        end
      end
    end
  end

  def self.boot_pins
    initialize_pin(17, :out)
    initialize_pin(18, :out)
    blink([:broken,:running], 0.1, :on, :off)
    blink([:broken,:running], 0.1, :on, :off)
  end

  def self.initialize_pin(number, direction)
    raise "Unkown direction #{status}" unless [:in,:out].include?(direction)
    `echo '#{number}' > /sys/class/gpio/unexport`
    `echo '#{number}' > /sys/class/gpio/export`
    `echo #{direction.to_s} > /sys/class/gpio/gpio#{number}/direction`
  end

  def self.build_status
    json_string = `curl -s https://www.codeship.io/api/v1/projects/#{PROJECT}.json\?api_key\=#{TOKEN}`
    json = JSON.parse(json_string)
    build = json['builds'].first
    status = build['status']
    return status.to_sym
  end

  def self.pin(name,status)
    raise "Unkown pin #{name}" unless PIN_MAP.include?(name)
    raise "Unkown status #{status}" unless [:on,:off].include?(status)
    number = PIN_MAP[name]
    if status==:on
      `echo 1 > /sys/class/gpio/gpio#{number}/value`
    elsif status==:off
      `echo 0 > /sys/class/gpio/gpio#{number}/value`
    end
  end

  def self.blink(pin_names,time_gap=0.1, start_state=:on, end_state=:off)
    pin_names.each do |name|
      pin(name,start_state)
    end
    sleep time_gap
    pin_names.each do |name|
      pin(name,end_state)
    end
  end
end

CodeshipBuildStatus.run!
