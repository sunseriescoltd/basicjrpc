module BasicJRPC
  class Client
    
    class Payload
      attr_reader :message_id, :method_name, :args
  
      def initialize(method_name, args)
        @message_id = SecureRandom.uuid
        @method_name = method_name
        @args = args
        @response_requested = response_requested
      end
  
      def response_requested bool
        @response_requested = bool
      end
    end
    
  end
end