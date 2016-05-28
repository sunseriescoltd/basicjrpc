module BasicJRPC
  
  # Responding Client
  class Client
    def initialize(queue)
      @redis = Redis.new(host: "redis")
      @queue = queue
      @payload = nil
    end
    
    def method_missing(m, *args, &block)
      send_request(Payload.new(m, args))
    end
    
    def send_request payload
      payload.response_requested true
      @redis.rpush(@queue, Oj.dump(payload))
      
      Timeout::timeout(5) {
        return Oj.load(@redis.blpop(payload.message_id)[1]) 
      }
    end
  end

  # Fire And Forget Client
  class FAFClient < Client
    def send_request payload
      payload.response_requested false
      @redis.rpush(@queue, Oj.dump(payload))
    end
  end
  
end
