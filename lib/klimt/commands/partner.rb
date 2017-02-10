module Klimt
  module Commands
    class Partner < Thor
      include Rendering

      desc 'locations PARTNER_ID [PARAMS]', 'Locations for a given partner, optionally filtered by PARAMS'
      method_option :private, desc: 'Also include where publicly_viewable=false', type: :boolean
      def locations(partner_id, *params)
        params << 'private=true' if options[:private]
        client = GravityClient.new(env: options[:env])
        response = client.partner_locations(id: partner_id, params: params)
        render response
      end

      desc 'near', 'Partners near a lat/lng point'
      method_option :y, type: :numeric, required: true, desc: 'Latitude'
      method_option :x, type: :numeric, required: true, desc: 'Longitude'
      method_option :eligible, type: :boolean, desc: 'Only where eligible_for_listing=true'
      method_option :type, desc: 'Filter only institutions or galleries', banner: 'PartnerInstitution | PartnerGallery'
      def near(*params)
        params << "near=#{options[:y]},#{options[:x]}"
        params << 'eligible_for_listing=true' if options[:eligible]
        client = GravityClient.new(env: options[:env])
        response = client.partner_near(params: params)
        render response
      end
    end
  end
end
