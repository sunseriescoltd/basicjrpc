module BasicJRPC
  class Server
        
    def initialize queue, injected_class, host="redis"
      @injected_class = injected_class
      @queue = queue
      #@nsq_consumer = Nsq::Consumer.new(nsqlookupd: 'dockerlb:4161', topic: @queue, channel: 'server')
      @host = host
    end
    
    def listen(trigger=nil, error_handler=nil)
      puts "Listening..."
      @redis = Redis.new(host: @host, port: 6381)
      
      while true
        begin
          redis_response = @redis.blpop(@queue)
          #@redis.rpush("#{@queue}-processing", redis_response)
        rescue Redis::TimeoutError
          puts "ERROR: Redis Read timed out. Retrying"
          retry
        end
        
        next if redis_response.nil?
        message = redis_response[1]
        
        payload = Oj.load(message, :symbol_keys => false)

        if payload.method_argument_type and payload.method_argument_type == "hash"
          response = @injected_class.send(payload.method_name, *payload.method_arguments.first.values)
        else
          response = @injected_class.send(payload.method_name, *payload.method_arguments)
        end

        @redis.rpush(payload.message_id, Oj.dump(response))
        
        @injected_class.send(trigger) if trigger
      end
    rescue Exception => e
      @redis.rpush(payload.message_id, Oj.dump(error_handler.handle(e))) if error_handler
      raise e
    end
    
    def terminate
      #@nsq_consumer.terminate
    end
    
  end
end
