require 'special_agent/base'
require 'special_agent/platform'
require 'special_agent/operating_system'
require 'special_agent/engine'
require 'special_agent/version'

module SpecialAgent
  class Device < Base
    attr_accessor :type, :name, :version
    attr_accessor :platform
    attr_accessor :operating_system
    attr_accessor :engine

    DEVICES = {
      :computer => 'windows|macintosh|x11|linux',
      :mobile => 'ipod|ipad|iphone|palm|android|opera mini|hiptop|windows ce|smartphone|mobile|treo|psp',
      :bot => 'bot|googlebot|crawler|spider|robot|crawling'
    }

    def parse(user_agent)
      SpecialAgent.debug "DEVICE PARSING", 2

      groups = parse_user_agent_string_into_groups(user_agent)
      groups.each_with_index do |content,i|
        if content[:comment] =~ /(#{DEVICES.collect{|cat,regex| regex}.join(')|(')})/i
          # Matched group against name
          self.populate(content)
        end
      end

      self.analysis

      self.platform = SpecialAgent::Platform.new(user_agent)
      self.operating_system = SpecialAgent::OperatingSystem.new(user_agent)
      self.engine = SpecialAgent::Engine.new(user_agent)
    end

    def populate(content={})
      self.debug_raw_content(content)
      SpecialAgent.debug "", 2

      self.type = self.determine_type(DEVICES, content[:comment])
      self.name = self.type.to_s.capitalize
      self.version = nil
      self
    end

    def analysis
      SpecialAgent.debug "DEVICE ANALYSIS", 2
      self.debug_content(:type => self.type, :name => self.name, :version => self.version)
      SpecialAgent.debug "", 2
    end

    def is_computer?(name=nil)
      if name
        case name
        when String
          return self.platform.name.downcase.include?(name.downcase)
        when Symbol
          return self.platform.name.downcase.include?(name.to_s.downcase)
        end
      else
        (self.type == :computer)
      end
    end

    def is_mobile?(name=nil)
      if !name.nil? && !self.platform.name.nil?
        case name
        when String
          return self.platform.name.downcase.include?(name.downcase) || self.platform.version.downcase.include?(name.downcase)
        when Symbol
          return self.platform.name.downcase.include?(name.to_s.downcase) || self.platform.version.to_s.downcase.include?(name.to_s.downcase)
        end
      else
        (self.type == :mobile)
      end
    end

    def is_bot?(name=nil)
      if name
        case name
        when String
          return self.name.downcase.include?(name.downcase)
        when Symbol
          return self.name.downcase.include?(name.to_s.downcase)
        end
      else
        (self.type == :bot)
      end
    end

    def to_s
      [self.name, self.version].compact.join(' ')
    end
  end
end
