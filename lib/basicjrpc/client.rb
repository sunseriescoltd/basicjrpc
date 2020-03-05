module BasicJRPC
  
  class Client
    def initialize(queue, timeout=10, host="redis")
      @queue = queue
      @payload = {}
      @timeout = timeout
      @instance_id = SecureRandom.hex(10)
      if host.is_a?(Array)
        @redis = Redis.new(cluster: host.map { |n| "redis://#{n}:6381" }, driver: :hiredis)
      elsif host.is_a?(String)
        @redis = Redis.new(host: host, port: 6381)
      end
    end
    
    def method_missing(m, *args, &block)
      if args.last.is_a?(Hash)
        if args.last.has_key?(:timeout)
          timeout = args.last[:timeout]
          args.last.delete(:timeout)
        end
        args.pop if args.last.is_a?(Hash) and args.last.empty?
      end
      timeout = @default_timeout if timeout.nil?
      payload = BasicJRPC::Data::RequestPayload.to_server(method_name: m.to_s, method_arguments: args, callers: caller.first(10), instance_id: @instance_id, message_id: SecureRandom.hex(10), method_argument_type: args.is_a?(Hash) ? "hash" : "array")
      send_request(payload, timeout)
    end
    
    def send_request data, timeout
      payload.response = true
      @redis.rpush(@queue, payload.to_json)
    
      response = @redis.blpop(payload.message_id, @timeout)
      raise "BasicJRPCResponseTimeout" if response.nil?
      
      ResponsePayload.from_server(response).to_response
    end
  end

  # Fire And Forget Client
  class FAFClient < Client
    def send_request payload
      @redis.rpush(@queue, JSON.dump(payload))
    end
  end
end
