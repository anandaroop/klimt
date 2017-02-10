require 'thor'
require 'klimt/commands/partner'
require 'klimt/commands/cities'
require 'klimt/rendering'

module Klimt
  class Command < Thor
    include Rendering

    map %w[--version -v] => 'version'

    class_option :env, desc: 'Choose environment', default: 'production', aliases: ['-e'], enum: %w(production staging)
    class_option :color, desc: 'Colorize output (via jq)', default: false, aliases: ['-c'], type: :boolean

    desc 'find TYPE ID', 'An instance of the given TYPE, identified by ID'
    def find(type, id)
      client = Klimt::GravityClient.new(env: options[:env])
      response = client.find(type: type, id: id)
      render response
    end

    desc 'list TYPE [PARAMS]', 'A list of the given TYPE, optionally filtered by PARAMS'
    def list(type, *params)
      client = Klimt::GravityClient.new(env: options[:env])
      response = client.list(type: type, params: params)
      render response
    end

    desc 'count TYPE [PARAMS]', 'A count of the given TYPE, optionally filtered by PARAMS'
    def count(type, *params)
      client = Klimt::GravityClient.new(env: options[:env])
      count = client.count(type: type, params: params)
      puts count
    end

    desc 'search TERM', 'Search results for the given TERM, optionally filtered by PARAMS'
    method_option :lucky, type: :boolean, desc: 'Feeling lucky? Just summarize the top hit', default: false
    method_option :indexes, type: :array, desc: 'An array of indexes to search', banner: 'Profile Artist etc...',
                            enum: %w(Article Artist Artist Artwork City Fair Feature Gene PartnerShow Profile Sale Tag)
    def search(term, *params)
      if options[:lucky]
        params << 'size=1'
        jq_filter = '.[0] | { model, id, display }'
      end
      indexes = options[:indexes] unless options[:indexes].nil?

      client = Klimt::GravityClient.new(env: options[:env])
      response = client.search(term: term, params: params, indexes: indexes)
      render response, jq_filter: jq_filter
    end

    desc "version", "print the version"
    def version
      puts Klimt::VERSION
    end

    # partner subcommands

    desc 'partner', 'View subcommands that pertain to partners'
    subcommand 'partner', Klimt::Commands::Partner

    # city subcommands

    desc 'cities', 'View subcommands that pertain to cities'
    subcommand 'cities', Klimt::Commands::Cities
  end
end
