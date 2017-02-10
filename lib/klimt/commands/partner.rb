require 'klimt/util/calculations'

module Klimt
  module Commands
    class Partner < Thor
      include Rendering

      CHECK = "\u2705".freeze
      CROSS = "\u274C".freeze
      RADIUS = '75km'.freeze

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

      desc 'check-locations [PARTNER_ID]', "Check correctness of a partner's location settings"
      method_option :y, type: :numeric, desc: 'Optionally, check only near given point'
      method_option :x, type: :numeric, desc: 'Optionally, check only near given point'
      def check_locations(partner_id)
        coords = options.values_at :y, :x
        if coords.any? && !coords.all?
          $stderr.puts 'Must provide both X and Y'
          exit 1
        end
        point = coords.all? ? coords.join(',') : nil
        client = GravityClient.new(env: options[:env])
        response = client.find(type: 'partner', id: partner_id)
        partner = JSON.parse(response)

        # subscriber or institution ?
        if institution?(partner)
          puts "#{CHECK}  Institution"
        elsif gallery?(partner) && current_subscriber?(partner)
          puts "#{CHECK}  Gallery with current subscription"
        else
          puts "#{CROSS}  Neither Institution nor current subscriber Gallery"
          exit 1
        end

        # pubished locations?
        public_count = published_locations_count(partner)
        if public_count.zero?
          puts "#{CROSS}  No publicly viewable locations"
          exit 1
        else
          puts "#{CHECK}  #{public_count} publicly viewable locations"
        end

        return if point.nil?
        # close enough to desired coords?
        near_count = published_locations_count(partner, point: point)
        if near_count.zero?
          puts "#{CROSS}  No publicly viewable locations within #{RADIUS} of #{point}"
          report_distances(partner, point: point)
          exit 1
        else
          puts "#{CHECK}  #{near_count} publicly viewable locations within #{RADIUS} of #{point}"
        end
      end

      private

      def gallery?(partner)
        partner['type'] == 'Gallery'
      end

      def institution?(partner)
        partner['type'] == 'Institution'
      end

      def current_subscriber?(partner)
        client = GravityClient.new(env: options[:env])
        params = [
          "partner_id=#{partner['id']}",
          'current=true'
        ]
        response = client.count(type: 'partner_subscriptions', params: params)
        count = response.to_i
        count.positive?
      end

      def published_locations_count(partner, point: nil)
        client = GravityClient.new(env: options[:env])
        params = []
        params << "near=#{point}" if point
        response = client.partner_locations_count(id: partner['id'], params: params)
        response.to_i
      end

      def unpublished_locations_count(partner, point: nil)
        client = GravityClient.new(env: options[:env])
        params = ['private=true']
        params << "near=#{point}" if point
        response = client.partner_locations_count(id: partner['id'], params: params)
        total_count = response.to_i
        published_count = published_locations_count(partner, point: point)
        (total_count - published_count)
      end

      def report_distances(partner, point:)
        params = ['private=true', 'size=100']
        client = GravityClient.new(env: options[:env])
        response = client.partner_locations(id: partner['id'], params: params)
        locations = JSON.parse(response)
        target_y, target_x = point.split(',').map(&:to_f)
        puts "   Partner location distances from #{target_y}, #{target_x}"
        puts '   ---------------------------------------------------------------------------'
        locations.each do |location|
          name, city, pub = location.values_at 'name', 'city', 'publicly_viewable'
          loc_y, loc_x = location['coordinates'].values_at('lat', 'lng')
          dist = Calculations.spherical_distance([loc_y, loc_x], [target_y, target_x])
          puts '   %20.20s | %15.15s | %4s | %7.1f km | (%+.4f, %+.4f)' % [name, city, (pub ? 'pub' : 'priv'), dist, loc_y, loc_x]
        end
      end
    end
  end
end
