module BasicJRPC
  class Server
            
    def initialize queue, injected_class, host="redis"
      if host.is_a?(Array)
        @redis = Redis.new(cluster: host.map { |n| "redis://#{n}:6381" }, driver: :hiredis)
      elsif host.is_a?(String)
        @redis = Redis.new(host: host, port: 6381)
      end
      @injected_class = injected_class
      @queue = queue
      @host = host
    end
    
    def listen(trigger=nil, error_handler=nil)
      puts "Listening..."
      
      while true
        begin
          redis_response = @redis.blpop(@queue)
        rescue Redis::TimeoutError
          puts "ERROR: Redis Read timed out. Retrying"
          retry
        end
        
        next if redis_response.nil?
        message = redis_response[1]
        
        payload = BasicJRPC::Data::RequestPayload.from_client(message)
        injected_class_response = @injected_class.send(payload.method_name, payload.args_data) if payload.method_argument_type == "hash"
        response_payload = BasicJRPC::Data::ResponsePayload.to_client(payload.message_id, injected_class_response)
        
        @redis.rpush(response_payload.message_id, response_payload.to_json)
      end
    rescue Exception => e
      @redis.rpush(payload.message_id, JSON.dump(error_handler.handle(e))) if error_handler
      raise e
    end
    
  end
end
