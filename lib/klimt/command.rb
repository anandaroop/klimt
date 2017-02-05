require 'thor'

module Klimt
  class Command < Thor
    class_option :env, desc: 'Choose environment', default: 'production', aliases: ['-e'], enum: ['production', 'staging']

    desc "find TYPE ID", "An instance of a given TYPE identified by ID"
    def find(type, id)
      client = Klimt::GravityClient.new(env: options[:env])
      response = client.find(type, id)
      puts JSON.pretty_generate JSON.parse(response)
    end
  end
end
