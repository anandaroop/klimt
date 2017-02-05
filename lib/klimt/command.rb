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

    private

    def render(obj)
      puts JSON.pretty_generate JSON.parse(obj)
    end

  end
end
