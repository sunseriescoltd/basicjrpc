require 'require_all'
require 'redis'
require 'oj'
require 'securerandom'
require 'basicjrpc'
require 'json'

gem_root = Gem::Specification.find_by_name("basicjrpc").gem_dir
require_all "#{gem_root}/lib/basicjrpc/**/*.rb"

module BasicJRPC
  class Config
    def self.set_debug val
      @@debug = val
    end
    
    def self.debug
      @@debug || false
    end
  end
end
