module BasicJRPC
  class Client
    
    class Payload
      attr_reader :message_id, :method_name, :args
      attr_accessor :response_requested
      
      def initialize(method_name, args)
        @message_id = SecureRandom.uuid
        @method_name = method_name
        @args = args
      end
        
    end
    
  end
end