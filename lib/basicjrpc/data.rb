require 'hashie' 

module BasicJRPC
  class TypeError < StandardError; end
  
  class Data
    class ResponsePayload
      attr_accessor :message_id
      attr_accessor :data

      PRIMITIVE_TYPES = [String, Array, NilClass, TrueClass, FalseClass, Fixnum, Bignum]
      SAFE_TYPES = [String, Array, NilClass, TrueClass, FalseClass, Fixnum, Bignum, Hashie::Mash, Hashie::Array]
      
      def self.to_client(message_id, data)
        # Data is just the data from the client, and we wrap it in an envelope
        rp = ResponsePayload.new
        rp.message_id = message_id
        rp.attach_data(data)
        rp
      end
      
      def self.from_server(message)
        # We need to unwrap the envelope and extract the message
        rp_message = JSON.load(message)
        rp = ResponsePayload.new
        rp.message_id = rp_message['message_id']
        rp.read_data(rp_message['data'])
        rp
      end
      
      def attach_data data
        if PRIMITIVE_TYPES.include?(data.class)
          @data = Hashie::Mash.new({ "response": data, "safe_mode": true })
        elsif data.is_a?(Hash)
          @data = Hashie::Mash.new(data)
        else
          raise BasicJRPC::TypeError.new
        end

        @data.extend(Hashie::Extensions::DeepLocate)
        found_unsafe_types = @data.deep_locate -> (key, value, object) { !SAFE_TYPES.include?(value.class)  }

        raise BasicJRPC::TypeError.new if found_unsafe_types.count > 0
      end
      
      def read_data data
        @data = Hashie::Mash.new(data)
      end
      
      def to_hash
        Hashie::Mash.new({
          message_id: @message_id,
          data: @data
          }).to_hash
      end
      
      def to_json
        JSON.dump(self.to_hash)
      end
      
      def to_response  
        if @data.safe_mode
          @data.response
        else
          @data
        end
      end
    end
    
    class RequestPayload
      attr_accessor :method_arguments
      attr_accessor :method_argument_type
      attr_accessor :method_name
      attr_accessor :message_id
      attr_accessor :instance_id
      attr_accessor :response
      attr_accessor :callers
      
      def self.to_server(method_name:, method_arguments:, callers:, instance_id:, message_id:, method_argument_type:)
        payload = Payload.new
        payload.parse_to_server(args)
        payload
      end
        
      def self.from_client(message)
        payload = Payload.new
        payload.parse_from_client(message)
        payload
      end
            
      def parse_from_client(message)
        payload = JSON.load(message)
        @method_arguments = payload['method_arguments']
        @method_argument_type = payload['method_argument_type']
        @method_name = payload['method_name']
        @message_id = payload['message_id']
        @instance_id = payload['instance_id']
        @response = payload['response']
        @callers = payload['callers']
      end
      
      def parse_to_server(message)
        @method_arguments = payload['method_arguments']
        @method_name = payload['method_name']
        @message_id = payload['message_id']
        @instance_id = payload['instance_id']
        @callers = payload['callers']
        @method_argument_type = payload['method_argument_type']
      end
      
      def args_data
        if @method_argument_type == "hash"
          # Send as hash, remove symbols and :
        elsif @method_argument_type == "array"
          # Send as array
        end
      end
      
      def to_hash
        Hashie::Mash.new({
          method_name: @method_name,
          method_arguments: @method_arguments,
          callers: @callers,
          instance_id: @instance_id,
          message_id: @message_id,
          method_argument_type: @method_argument_type
          }).to_hash
      end
      
      def to_json
        JSON.dump(self.to_hash)
      end
    end
    
  end
end