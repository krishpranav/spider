require 'spider/settings/proxy'
require 'spider/settings/timeouts'
require 'spider/settings/user_agent'
require 'spider/agent'

module Spider
  extend Settings::Proxy
  extend Settings::Timeouts
  extend Settings::UserAgent


  def self.robots?
    @robots ||= false
    @robots
  end


  def self.robots=(mode)
    @robots = mode
  end

  def self.start_at(url,options={},&block)
    Agent.start_at(url,options,&block)
  end

  def self.host(name,options={},&block)
    Agent.host(name,options,&block)
  end

  def self.site(url,options={},&block)
    Agent.site(url,options,&block)
  end

  def self.robots
  end
end