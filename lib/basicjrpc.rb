require "basicjrpc/version"
require 'redis'
require 'oj'
require 'securerandom'

module BasicJRPC
  class Client
    
    class Payload
      attr_reader :message_id, :method_name, :args
      
      def initialize(method_name, args)
        @message_id = SecureRandom.uuid
        @method_name = method_name
        @args = args
      end
    end
    
    def initialize(queue)
      @redis = Redis.new
      @queue = queue
      @payload = nil
    end
    
    def method_missing(m, *args, &block)
      send_request(Payload.new(m, args))
    end
    
    def send_request payload
      @redis.rpush(@queue, Oj.dump(payload))
      Oj.load(@redis.blpop(payload.message_id)[1])
    end
  end
  
  class Server
        
    def initialize queue, injected_class
      @injected_class = injected_class
      @queue = queue
      @redis = Redis.new
    end
    
    def listen
      puts "Listening..."
      while true
        payload = @redis.blpop(@queue)[1]
        payload = Oj.load(payload)
        puts "Processing message #{payload}"
        
        # Should always return a data object
        response = @injected_class.send(payload.method_name, *payload.args)
          
        # Bounce the response back
        @redis.rpush(payload.message_id, Oj.dump(response))
      end
    end
  end
end
