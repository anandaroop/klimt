require 'byebug'
require "spec_helper"
require 'webmock/rspec'

RSpec.describe Klimt::GravityClient do
  describe "constructor" do
    it "requires an env: argument" do
      expect{ client = described_class.new }.to raise_error ArgumentError
    end
  end

  describe "instance methods" do
    let(:client) { described_class.new(env: 'test') } 
    before do
      stub_netrc_authentication
    end

    describe '#find' do
      it 'requires a type: argument' do
        expect { client.find(id: 'eyebeam') }.to raise_error ArgumentError, 'missing keyword: type'
      end
      it 'requires a id: argument' do
        expect { client.find(type: 'partner') }.to raise_error ArgumentError, 'missing keyword: id'
      end
      it 'makes the correct API request' do
        stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/partner/eyebeam')
        client.find(type: 'partner', id: 'eyebeam')
        expect(stub).to have_been_requested
      end
    end
  end

end
