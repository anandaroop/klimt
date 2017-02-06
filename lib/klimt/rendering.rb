module Rendering
  def render(obj)
    puts JSON.pretty_generate JSON.parse(obj)
  end
end
