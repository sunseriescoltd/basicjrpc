require 'rspec/autorun'
require 'require_all'

$LOAD_PATH.unshift(File.dirname(__FILE__)+'/lib')

require_all "./lib/**/*.rb"

describe BasicJRPC::Data::ResponsePayload do
  it "builds a response using a hash" do
    data = { "a" => "a" }
    response_payload = BasicJRPC::Data::ResponsePayload.to_client("1234", data)
    expect(response_payload.to_response).to eq({ "a" => "a" })
  end
  it "hash can be accessed using methods" do
    data = { name: "martin" }
    response_payload = BasicJRPC::Data::ResponsePayload.to_client("1234", data)
    expect(response_payload.to_response.name).to eq("martin")
  end  
  it "hash can be accessed using key" do
    data = { name: "martin" }
    response_payload = BasicJRPC::Data::ResponsePayload.to_client("1234", data)
    expect(response_payload.to_response["name"]).to eq("martin")
  end  
  it "hash can be accessed using symbol" do
    data = { name: "martin" }
    response_payload = BasicJRPC::Data::ResponsePayload.to_client("1234", data)
    expect(response_payload.to_response[:name]).to eq("martin")
  end
end
