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
        
        payload = JSON.load(message, :symbol_keys => false)

        if payload['method_argument_type'] and payload.method_argument_type == "hash"
          if @injected_class.method(payload.method_name).parameters.flatten.include?(:keyreq)
            data = {}
            payload.method_arguments.first.each { |k,v| data[k.gsub(":", "")] = v }
            data.symbolize_keys!
            response = @injected_class.send(payload.method_name, data)
          else
            response = @injected_class.send(payload.method_name, *payload.method_arguments.first.values)
          end
        else
          if payload.method_arguments.first.is_a?(Hash)
            data = {}
            payload.method_arguments.first.each { |k,v| data[k.gsub(":", "")] = v }
            data.symbolize_keys!
          else
            data = *payload.method_arguments
          end
          response = @injected_class.send(payload.method_name, data)
        end

        @redis.rpush(payload.message_id, JSON.dump(response))
        
        @injected_class.send(trigger) if trigger
      end
    rescue Exception => e
      @redis.rpush(payload.message_id, JSON.dump(error_handler.handle(e))) if error_handler
      raise e
    end
    
  end
end
