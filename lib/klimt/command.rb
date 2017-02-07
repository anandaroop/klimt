require 'thor'
require 'klimt/commands/partner'
require 'klimt/rendering'

module Klimt
  class Command < Thor
    include Rendering

    class_option :env, desc: 'Choose environment', default: 'production', aliases: ['-e'], enum: ['production', 'staging']

    desc "find TYPE ID", "An instance of the given TYPE, identified by ID"
    def find(type, id)
      client = Klimt::GravityClient.new(env: options[:env])
      response = client.find(type: type, id: id)
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
      indexes = options[:indexes] unless options[:indexes].nil?
      client = Klimt::GravityClient.new(env: options[:env])
      response = client.search(term, params, indexes)
      render response
    end

    # partner subcommands

    desc 'partner', 'View subcommands that pertain to partners'
    subcommand "partner", Klimt::Commands::Partner

  end
end
