require 'spec_helper'

describe NidApi do
  let(:nid) { 118000023427 }
  let(:uri) { "https://stats.ivote.ly/voter/#{nid}" }

  describe ".get" do
    before do
      stub_request(:get, uri).
        to_return(successful_response)
    end

    it "should respond" do
      NidApi.should respond_to :get
    end

    it "requires one argument" do
      expect { NidApi.get }.to raise_error ArgumentError
    end

    it "should make a request" do
      NidApi.get(nid)
      a_request(:get, uri).should have_been_made
    end

    it "should return hash" do
      NidApi.get(nid).should be_an_instance_of Hash
    end

    it "should return nil if 404" do
      stub_request(:get, uri).
        to_return(unsuccessful_response)
      NidApi.get(nid).should be_nil
    end
  end
end
