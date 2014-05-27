require 'json'

class CodeshipBuildStatus
  TOKEN = ENV['CODESHIP_TOKEN']
  PROJECT = ENV['CODESHIP_PROJECT']
  def self.run!
    raise 'I need both CODESHIP_TOKEN and CODESHIP_PROJECT env var to be set!' unless ENV['CODESHIP_TOKEN'] && ENV['CODESHIP_PROJECT']
    boot_pins
    trap("SIGINT") do
      puts 'Bye bye!'
      pin(17,:off) # alert the script is down!
      exit!
    end
    puts 'Starting...'
    while true do
      if build_status==:success
        puts 'Build is good'
        pin(17,:off)
      else
        puts 'Build is bad'
        pin(17,:on)
      end
    end
  end

  def self.boot_pins
    `echo '17' > /sys/class/gpio/unexport`
    `echo '17' > /sys/class/gpio/export`
    `echo out > /sys/class/gpio/gpio17/direction`
    pin(17,:on)
    sleep 0.1
    pin(17,:off)
    sleep 0.1
    pin(17,:on)
    sleep 0.1
    pin(17,:off)
  end

  def self.build_status
    json_string = `curl -s https://www.codeship.io/api/v1/projects/#{PROJECT}.json\?api_key\=#{TOKEN}`
    json = JSON.parse(json_string)
    build = json['builds'].first
    status = build['status']
    return status.to_sym
  end

  def self.pin(number,status)
    if status==:on
      `echo 1 > /sys/class/gpio/gpio#{number}/value`
    elsif status==:off
      `echo 0 > /sys/class/gpio/gpio#{number}/value`
    else
      raise 'wft?'
    end
  end
end

CodeshipBuildStatus.run!