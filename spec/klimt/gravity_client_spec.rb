require 'byebug'
require 'spec_helper'
require 'webmock/rspec'

RSpec.describe Klimt::GravityClient do
  describe 'constructor' do
    it 'requires an env: argument' do
      expect { described_class.new }.to raise_error ArgumentError
    end
  end

  describe 'instance methods' do
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

    describe '#list' do
      it 'requires a type: argument' do
        expect { client.list }.to raise_error ArgumentError, 'missing keyword: type'
      end
      it 'makes the correct API request' do
        stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/partners')
        client.list(type: 'partners')
        expect(stub).to have_been_requested
      end
      context 'with query parameters' do
        it 'makes the correct API request' do
          stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/partners?foo=bar')
          client.list(type: 'partners', params: ['foo=bar'])
          expect(stub).to have_been_requested
        end
      end
    end

    describe '#count' do
      it 'requires a type: argument' do
        expect { client.count }.to raise_error ArgumentError, 'missing keyword: type'
      end
      it 'makes the correct API request' do
        stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/partners')
                      .with(query: { size: '0', total_count: 'true' })
                      .to_return(body: '', headers: { 'X-Total-Count' => 1 })
        client.count(type: 'partners')
        expect(stub).to have_been_requested
      end
      context 'with query parameters' do
        it 'makes the correct API request' do
          stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/partners')
                        .with(query: { size: '0', total_count: 'true', foo: 'bar' })
                        .to_return(body: '', headers: { 'X-Total-Count' => 1 })
          client.count(type: 'partners', params: ['foo=bar'])
          expect(stub).to have_been_requested
        end
      end
    end

    describe '#search' do
      it 'requires a term: argument' do
        expect { client.search }.to raise_error ArgumentError, 'missing keyword: term'
      end
      it 'makes the correct API request' do
        stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/match?term=shark')
        client.search(term: 'shark')
        expect(stub).to have_been_requested
      end
      context 'with query parameters' do
        it 'makes the correct API request' do
          stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/match')
                        .with(query: { term: 'shark', foo: 'bar' })
          client.search(term: 'shark', params: ['foo=bar'])
          expect(stub).to have_been_requested
        end
      end
      context 'with a list of indexes' do
        it 'adds the indexes as a proper array parameter' do
          stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/match')
                        .with(query: { term: 'shark', indexes: %w(Artwork Article) })
          client.search(term: 'shark', indexes: %w(Artwork Article))
        end
      end
    end
  end
end
