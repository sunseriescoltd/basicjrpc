module BasicJRPC
  
  class Client
    def initialize(queue, timeout=10, host="redis")
      @queue = queue
      @payload = {}
      @timeout = timeout
      @instance_id = SecureRandom.uuid
      if host.is_a?(Array)
        @redis = Redis.new(cluster: host.map { |n| "redis://#{n}:6381" }, driver: :hiredis)
      elsif host.is_a?(String)
        @redis = Redis.new(host: @host, port: 6381)
      end
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
      Oj.load(@redis.blpop(payload['message_id'], timeout: @timeout)[1], :symbol_keys => true)
    end
    
  end

  # Fire And Forget Client
  class FAFClient < Client
    def send_request payload
      payload['message_id'] = SecureRandom.uuid
      payload['response'] = true
      payload['caller'] = caller.first(10)
      @redis.rpush(@queue, Oj.dump(payload))
    end
  end
end
