module BasicJRPC
  class Server
        
    def initialize queue, injected_class
      @injected_class = injected_class
      @queue = queue
      @nsq_consumer = Nsq::Consumer.new(nsqlookupd: 'dockerlb:4161', topic: @queue, channel: 'server')
    end
    
    def listen
      puts "Listening..."
      while true
        message = @nsq_consumer.pop
        payload = Oj.load(message.body)
        puts "Processing message #{payload.method_name} #{payload.method_arguments}"
        
        # Should always return a data object
        response = @injected_class.send(payload.method_name, *payload.method_arguments)

        Redis.new(host: "redis").rpush(payload.message_id, Oj.dump(response))
        message.finish
      end
    end
    
  end
end
