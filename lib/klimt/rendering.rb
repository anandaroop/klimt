module Rendering
  def render(obj)
    if jq_installed?
      render_with_jq(obj)
    else
      render_pretty(obj)
    end
  end

  def render_with_jq(obj)
    cmd = if options[:color]
      "jq -C"
    else
      "jq"
    end
    IO.popen("#{cmd} '.'", 'r+') do |p|
      p.write obj
      p.close_write
      puts p.read
    end
  end

  def render_pretty(obj)
    puts JSON.pretty_generate JSON.parse(obj)
  end

  def jq_installed?
    !%x{command -v jq}.empty?
  end
end
