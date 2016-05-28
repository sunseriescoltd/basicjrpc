module BasicJRPC
  class Server
        
    def initialize queue, injected_class
      @injected_class = injected_class
      @queue = queue
      @redis = Redis.new(host: "redis")
    end
    
    def listen
      puts "Listening..."
      while true
        payload = @redis.blpop(@queue)[1]
        payload = Oj.load(payload)
        puts "Processing message #{payload.method_name} #{payload.args}" if BasicJRPC::Config.debug
        
        # Should always return a data object
        response = @injected_class.send(payload.method_name, *payload.args)
          
        # Bounce the response back if response is requested
        @redis.rpush(payload.message_id, Oj.dump(response)) if payload.response_requested
      end
    end
    
  end
end
