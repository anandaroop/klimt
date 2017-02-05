require 'thor'

module Klimt
  class Command < Thor
    class_option :env, desc: 'Choose environment', default: 'production', aliases: ['-e'], enum: ['production', 'staging']

    desc "find TYPE ID", "An instance of the given TYPE, identified by ID"
    def find(type, id)
      client = Klimt::GravityClient.new(env: options[:env])
      response = client.find(type, id)
      render response
    end

    desc "list TYPE [PARAMS]", "A list of the given TYPE, optionally filted by PARAMS"
    def list(type, *params)
      client = Klimt::GravityClient.new(env: options[:env])
      response = client.list(type, params)
      render response
    end

    desc "count TYPE [PARAMS]", "A count of the given TYPE, optionally filted by PARAMS"
    def count(type, *params)
      client = Klimt::GravityClient.new(env: options[:env])
      count = client.count(type, params)
      puts count
    end

    desc "search TERM", "Search results for the given TERM, optionally filted by PARAMS"
    method_option :indexes, type: :array, desc: 'An array of indexes to search', banner: 'Profile Artist etc...'
    def search(term, *params)
      client = Klimt::GravityClient.new(env: options[:env])
      response = client.search(term, params, options)
      render response
    end

    private

    def render(obj)
      puts JSON.pretty_generate JSON.parse(obj)
    end

  end
end
