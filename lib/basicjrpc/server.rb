module BasicJRPC
  class Server
        
    def initialize queue, injected_class, host="redis"
      @injected_class = injected_class
      @queue = queue
      #@nsq_consumer = Nsq::Consumer.new(nsqlookupd: 'dockerlb:4161', topic: @queue, channel: 'server')
      @host = host
    end
    
    def listen
      puts "Listening..."
      @redis = Redis.new(host: @host)
      
      while true
        begin
          redis_response = @redis.brpop(@queue)
        rescue Redis::TimeoutError
          puts "ERROR: Redis Read timed out. Retrying"
          retry
        end
        
        next if redis_response.nil?
        message = redis_response[1]
        
        payload = Oj.load(message, :symbol_keys => false)

        response = @injected_class.send(payload.method_name, *payload.method_arguments)

        @redis.rpush(payload.message_id, Oj.dump(response))
      end
    rescue Exception => e
      raise e
    end
    
    def terminate
      #@nsq_consumer.terminate
    end
    
  end
end
