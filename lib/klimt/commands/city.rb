module Klimt
  module Commands
    class City < Thor
      include Rendering

      desc 'list', 'List all currently geocoded cities from S3'
      method_option :featured, desc: 'Restrict to just "featured" cities', type: :boolean
      method_option :short, desc: 'Show compact output', type: :boolean
      def list
        file = options[:featured] ? 'featured-cities.json' : 'cities.json'
        uri = "http://artsy-geodata.s3-website-us-east-1.amazonaws.com/partner-cities/#{file}"
        response = Typhoeus.get(uri)
        jq_filter = options[:short] ? '.[] | { full_name, coords }' : '.'
        jq_options = options[:short] ? '-c' : ''
        render response.body, jq_filter: jq_filter, jq_options: jq_options
      end
    end
  end
end
