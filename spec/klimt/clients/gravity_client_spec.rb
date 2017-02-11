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
      stub_netrc_gravity_authentication
    end

    describe 'core methods' do
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
            expect(stub).to have_been_requested
          end
        end
      end
    end

    describe 'additional methods for partners' do
      describe '#partner_locations' do
        it 'requires a id: argument' do
          expect { client.partner_locations }.to raise_error ArgumentError, 'missing keyword: id'
        end
        it 'makes the correct API request' do
          stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/partner/eyebeam/locations')
          client.partner_locations(id: 'eyebeam')
          expect(stub).to have_been_requested
        end
        context 'with query parameters' do
          it 'makes the correct API request' do
            stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/partner/eyebeam/locations?foo=bar')
            client.partner_locations(id: 'eyebeam', params: ['foo=bar'])
            expect(stub).to have_been_requested
          end
        end
      end

      describe '#partner_locations_count' do
        it 'requires a id: argument' do
          expect { client.partner_locations_count }.to raise_error ArgumentError, 'missing keyword: id'
        end
        it 'makes the correct API request' do
          stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/partner/eyebeam/locations')
                        .with(query: { size: '0', total_count: 'true' })
                        .to_return(body: '', headers: { 'X-Total-Count' => 1 })
          client.partner_locations_count(id: 'eyebeam')
          expect(stub).to have_been_requested
        end
        context 'with query parameters' do
          it 'makes the correct API request' do
            stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/partner/eyebeam/locations')
                          .with(query: { size: '0', total_count: 'true', foo: 'bar' })
                          .to_return(body: '', headers: { 'X-Total-Count' => 1 })
            client.partner_locations_count(id: 'eyebeam', params: ['foo=bar'])
            expect(stub).to have_been_requested
          end
        end
      end

      describe '#partner_near' do
        it 'requires a "near" parameter' do
          expect { client.partner_near(params: []) }.to raise_error ArgumentError, /near.*required/
        end
        it 'makes the correct API request' do
          stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/partners?near=30,-90')
          params = ['near=30,-90']
          client.partner_near(params: params)
          expect(stub).to have_been_requested
        end
        context 'with query parameters' do
          it 'makes the correct API request' do
            stub = WebMock.stub_request(:get, 'https://api.artsy.biz/api/v1/partners')
                          .with(query: { near: '30,-90', foo: 'bar' })
            client.partner_near(params: ['foo=bar', 'near=30,-90'])
            expect(stub).to have_been_requested
          end
        end
      end
    end
  end
end
