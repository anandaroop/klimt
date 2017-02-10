module Klimt
  module Commands
    class Partner < Thor
      include Rendering

      desc 'locations PARTNER_ID [PARAMS]', 'Locations for a given partner, optionally filtered by PARAMS'
      method_option :private, desc: 'Also include where publicly_viewable=false', type: :boolean
      def locations(partner_id, *params)
        params << 'private=true' if options[:private]
        client = Klimt::GravityClient.new(env: options[:env])
        response = client.partner_locations(partner_id, params)
        render response
      end
    end
  end
end
