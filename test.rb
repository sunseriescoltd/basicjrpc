require 'rspec/autorun'
require 'require_all'

$LOAD_PATH.unshift(File.dirname(__FILE__)+'/lib')

require_all "./lib/**/*.rb"

describe BasicJRPC::Data::ResponsePayload do
  it "builds a response using a hash" do
    data = { "a" => "a" }
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    expect(r2).to eq({ "a" => "a" })
  end
  it "hash can be accessed using methods" do
    data = { name: "martin" }
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    
    response_payload = BasicJRPC::Data::ResponsePayload.to_client("1234", data)
    expect(r2.name).to eq("martin")
  end  
  it "hash can be accessed using key" do
    data = { name: "martin" }
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    expect(r2["name"]).to eq("martin")
  end  
  it "hash can be accessed using symbol" do
    data = { name: "martin" }
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    expect(r2[:name]).to eq("martin")
  end
  it "nil can be passed" do
    data = nil
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    expect(r2).to eq(nil)
  end
  it "true can be passed" do
    data = true
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    expect(r2).to eq(true)
  end
  it "false can be passed" do
    data = false
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    expect(r2).to eq(false)
  end
  it "Fixnum can be passed" do
    data = 2347234
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    expect(r2).to eq(2347234)
  end
  it "mixed hash is converted" do
    data = {
      "nested_hash": {
        a: "test1",
        b: "test2",
        "c": "test3"
      }
    }
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    expect(r2).to eq({ "nested_hash" => { "a" => "test1", "b" => "test2", "c" => "test3"}})
  end
  it "mixed hash is accessible by methods" do
    data = {
      "nested_hash": {
        a: "test1",
        b: "test2",
        "c": "test3"
      }
    }
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    expect(r2.nested_hash.a).to eq("test1")
  end
  
  it "mixed hash and array is converted" do
    data = {
      "nested_hash": [
        {
          a: "test1",
          b: "test2",
          "c": "test3"
        }
      ]
    }
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    expect(r2).to eq({ "nested_hash" => [ { "a" => "test1", "b" => "test2", "c" => "test3"}]})
  end
  
  it "mixed hash and array is accesible by methods" do
    data = {
      "nested_hash": [
        {
          a: "test1",
          b: "test2",
          "c": "test3"
        }
      ]
    }
    r1 = BasicJRPC::Data::ResponsePayload.to_client("1234", data).to_json
    r2 = BasicJRPC::Data::ResponsePayload.from_server(r1).to_response
    expect(r2.nested_hash.first.b).to eq("test2")
  end
  it "mixed hash and array cant have custom types" do
    class CustomClass
      attr_accessor :name
    end
    
    custom_object = CustomClass.new
    custom_object.name = "martin"
    
    data = {
      "nested_hash": [
        {
          a: custom_object
        }
      ]
    }
    
    expect {
      response_payload = BasicJRPC::Data::ResponsePayload.to_client("1234", data)
    }.to raise_error(BasicJRPC::TypeError)
  end
  
  
end
