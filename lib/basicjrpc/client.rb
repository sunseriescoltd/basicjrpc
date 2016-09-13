require 'timeout'


##### WARNING
##### WARNING
##### THERE IS NO DEAD-CLIENT PROTECTION
##### THIS WILL DAMAGE UPSTREAM REQUESTS UNTIL RELOADED

module BasicJRPC
  
  # Responding Client
  class Client
    def initialize(queue, timeout = 5)
      @queue = queue
      @payload = {}
      @timeout = timeout
      @instance_id = SecureRandom.uuid
      @nsq_producer = Nsq::Producer.new(nsqd: 'dockerlb:4150', topic: @queue)
    end
    
    def method_missing(m, *args, &block)
      send_request({ :method_name => m, :method_arguments => args })
    end
    
    def send_request payload
      payload[:message_id] = SecureRandom.uuid
      payload[:instance_id] = @instance_id
      payload[:response] = true
            
      my_message = false
      
      @nsq_producer.write(Oj.dump(payload))
      
      Timeout::timeout(5) {
        Oj.load(Redis.new(host: "redis").blpop(payload[:message_id])[1])
      }
    end
    
    # This must be called
    def terminate
      nsq_producer.terminate
    end
  end

  # Fire And Forget Client
  class FAFClient < Client
    def send_request payload
      payload[:message_id] = SecureRandom.uuid
      payload[:response] = true
      @nsq_producer.write(Oj.dump(payload))
    end
  end
  
end
