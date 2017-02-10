module Klimt
  module Commands
    module Rendering
      def render(obj, jq_options: nil, jq_filter: nil)
        if jq_installed?
          render_with_jq(obj, opts: jq_options, filter: jq_filter)
        else
          render_pretty(obj)
        end
      end

      def render_with_jq(obj, opts: nil, filter: nil)
        opts ||= ''
        opts << ' -C' if options[:color]
        filter ||= '.'
        IO.popen("jq #{opts} \"#{filter}\"", 'r+') do |p|
          p.write obj
          p.close_write
          puts p.read
        end
      end

      def render_pretty(obj)
        puts JSON.pretty_generate JSON.parse(obj)
      end

      def jq_installed?
        !`command -v jq`.empty?
      end
    end
  end
end
