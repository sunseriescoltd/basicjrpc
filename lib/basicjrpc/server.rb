module BasicJRPC
  class Server
        
    def initialize queue, injected_class
      @injected_class = injected_class
      @queue = queue
      #@nsq_consumer = Nsq::Consumer.new(nsqlookupd: 'dockerlb:4161', topic: @queue, channel: 'server')
      @redis = Redis.new(host: "redis")
    end
    
    def listen
      puts "Listening..."
      while true
        redis_response = @redis.brpop(@queue, { :timeout => 10 })
        next if redis_response.nil?
        message = redis_response[1]
        
        #message = @nsq_consumer.pop
        
        payload = Oj.load(message)
        puts "Processing message #{payload.message_id} #{payload.method_name} #{payload.method_arguments} #{payload.callers}"
        
        # Should always return a data object
        response = @injected_class.send(payload.method_name, *payload.method_arguments)

        @redis.rpush(payload.message_id, Oj.dump(response))
        #message.finish
      end
    rescue Exception => e
      #message.finish
      #terminate
      raise e
    end
    
    def terminate
      #@nsq_consumer.terminate
    end
    
  end
end
