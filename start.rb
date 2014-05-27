require 'json'

class CodeshipBuildStatus
  TOKEN = ENV['CODESHIP_TOKEN']
  PROJECT = ENV['CODESHIP_PROJECT']
  def self.run!
    raise 'I need both CODESHIP_TOKEN and CODESHIP_PROJECT env var to be set!' unless ENV['CODESHIP_TOKEN'] && ENV['CODESHIP_PROJECT']
    boot_pins
    trap("SIGINT") do
      puts 'Bye bye!'
      pin(17,:on) # alert the script is down!
      exit!
    end
    puts 'Starting...'
    while true do
      if build_status==:success
        puts 'Build is good'
        pin(17,:on)
      else
        puts 'Build is bad'
        pin(17,:off)
      end
    end
  end

  def self.boot_pins
    `echo '17' > /sys/class/unexport`
    `echo '17' > /sys/class/export`
    `echo out > /sys/class/gpio17/direction`
    `echo 1 > /sys/class/gpio17/value`
    sleep 1
    `echo 0 > /sys/class/gpio17/value`
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
      `echo 1 > /sys/class/gpio#{number}/value`
    elsif status==:off
      `echo 0 > /sys/class/gpio#{number}/value`
    else
      raise 'wft?'
    end
  end
end

CodeshipBuildStatus.run!