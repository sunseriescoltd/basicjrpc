require 'timeout'


##### WARNING
##### WARNING
##### THERE IS NO DEAD-CLIENT PROTECTION
##### THIS WILL DAMAGE UPSTREAM REQUESTS UNTIL RELOADED

module BasicJRPC
  
  # Responding Client
  class Client
    def initialize(queue, timeout=10, host="redis")
      @queue = queue
      @payload = {}
      @timeout = timeout
      @instance_id = SecureRandom.uuid
      #@nsq_producer = Nsq::Producer.new(nsqd: 'dockerlb:4150', topic: @queue)
      @redis = Redis.new(host: host, port: 6381)
    end
    
    def method_missing(m, *args, &block)
      send_request({ 'method_name' => m.to_s, 'method_arguments' => args, 'callers' => caller.first(10) })
    end
    
    def send_request payload
      payload['message_id'] = SecureRandom.uuid
      payload['instance_id'] = @instance_id
      payload['response'] = true
            
      my_message = false
      
      @redis.rpush(@queue, Oj.dump(payload))
      
      Timeout::timeout(@timeout) {
        Oj.load(@redis.blpop(payload['message_id'])[1], :symbol_keys => true)
      }
    rescue Exception => e
      #terminate
      raise e
    end
    
    # This must be called
    def terminate
      #@nsq_producer.terminate
    end
  end

  # Fire And Forget Client
  class FAFClient < Client
    def send_request payload
      payload['message_id'] = SecureRandom.uuid
      payload['response'] = true
      payload['caller'] = caller.first(10)
      @redis.rpush(@queue, Oj.dump(payload))
    rescue Exception => e
      #terminate
      raise e
    end
  end
end
