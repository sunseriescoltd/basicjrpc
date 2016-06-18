module BasicJRPC
  
  # Responding Client
  class Client
    def initialize(queue, timeout = 5)
      @redis = Redis.new(host: "redis")
      @queue = queue
      @payload = {}
      @timeout = timeout
    end
    
    def method_missing(m, *args, &block)
      send_request({ method_name: m, method_arguments: *args })
    end
    
    def send_request payload
      payload[:message_id] = SecureRandom.uuid
      payload[:response] = true
      
      @redis.rpush(@queue, Oj.dump(payload))
      
      Timeout::timeout(@timeout) {
        return Oj.load(@redis.blpop(payload[:message_id])[1]) 
      }
    end
  end

  # Fire And Forget Client
  class FAFClient < Client
    def send_request payload
      payload[:message_id] = SecureRandom.uuid
      payload[:response] = true
      @redis.rpush(@queue, Oj.dump(payload))
    end
  end
  
end
