require 'netrc'
require 'highline'
require 'typhoeus'
require 'json'

module Klimt
  class GravityClient
    attr_reader :token

    HOSTS = { production: 'api.artsy.net', staging: 'stagingapi.artsy.net' }.freeze
    DEFAULT_PAGE_SIZE = 20

    def initialize(env:)
      @host = host_from_environment(env)
      @token = find_or_create_token
    end

    def find(type:, id:)
      uri = "https://#{@host}/api/v1/#{type}/#{id}"
      response = Typhoeus.get(uri, headers: headers)
      fail response.body unless response.success?
      response.body
    end

    def list(type:, params: [])
      params = parse_params(params)
      uri = "https://#{@host}/api/v1/#{type}"
      response = Typhoeus.get(uri, headers: headers, params: params)
      fail response.body unless response.success?
      response.body
    end

    def count(type:, params: [])
      params = parse_params(params)
      params[:size] = 0
      params[:total_count] = true
      uri = "https://#{@host}/api/v1/#{type}"
      response = Typhoeus.get(uri, headers: headers, params: params)
      response.headers['X-Total-Count']
    end

    def search(term:, params: [], indexes: nil)
      params = parse_params(params)
      params[:term] = term
      params[:indexes] = indexes unless indexes.nil?
      uri = "https://#{@host}/api/v1/match"
      response = Typhoeus.get(uri, headers: headers, params: params, params_encoding: :rack) # encode arrays correctly
      fail response.body unless response.success?
      response.body
    end

    # partners

    def partner_locations(id:, params: [])
      params = parse_params(params)
      uri = "https://#{@host}/api/v1/partner/#{id}/locations"
      response = Typhoeus.get(uri, headers: headers, params: params)
      fail response.body unless response.success?
      response.body
    end

    def partner_locations_count(id:, params: [])
      params = parse_params(params).merge(size: 0, total_count: true)
      uri = "https://#{@host}/api/v1/partner/#{id}/locations"
      response = Typhoeus.get(uri, headers: headers, params: params)
      response.headers['X-Total-Count']
    end

    def partner_near(params: [])
      params = parse_params(params)
      raise ArgumentError, 'a "near=LNG,LAT" parameter is required' unless params.include? 'near'
      uri = "https://#{@host}/api/v1/partners"
      response = Typhoeus.get(uri, headers: headers, params: params)
      fail response.body unless response.success?
      response.body
    end

    private

    # Turn this from the command line:
    #   ["size=10", "page=2"]
    # into this for Typhoeus:
    #   {'size' => 10, 'page' => 2}
    #
    def parse_params(params)
      Hash[params.map { |pair| pair.split('=') }]
    end

    def headers
      {
        'User-Agent' => "Klimt #{Klimt::VERSION}",
        'Content-type' => 'application/json',
        'Accept' => 'application/json',
        'X-ACCESS-TOKEN' => @token
      }
    end

    def host_from_environment(env)
      HOSTS[env.to_sym]
    end

    def find_or_create_token
      _user, token = Netrc.read[@host]
      token || generate_token
    end

    def generate_token
      email, pass = ask_for_credentials
      params = {
        client_id: ENV['KLIMT_ID'],
        client_secret: ENV['KLIMT_SECRET'],
        grant_type: 'credentials',
        email: email,
        password: pass
      }
      response = Typhoeus.get "https://#{@host}/oauth2/access_token", params: params
      body = JSON.parse(response.body)
      quit "Login failed: #{body['error_description']}" unless response.success?
      body['access_token'].tap do |new_token|
        netrc = Netrc.read
        netrc[@host] = email, new_token
        netrc.save
      end
    end

    def quit(msg)
      $stderr.puts msg
      exit 1
    end

    def ask_for_credentials
      cli = HighLine.new
      cli.say 'No login credentials found in .netrc'
      cli.say 'Please login now'
      cli.say '-----'
      email = cli.ask('Artsy email    : ') {}
      pass  = cli.ask('Artsy password : ') { |q| q.echo = 'x' }
      [email, pass]
    end
  end
end
