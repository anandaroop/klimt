include Math
module Calculations
  # Haversine formula for spherical distance
  # See: https://rosettacode.org/wiki/Haversine_formula#Ruby

  RADIUS = 6371 # rough radius of the Earth, in kilometers

  def self.spherical_distance(start_latlng, end_latlng)
    lat1, long1 = deg2rad(*start_latlng)
    lat2, long2 = deg2rad(*end_latlng)
    2 * RADIUS * asin(sqrt(sin((lat2 - lat1) / 2)**2 + cos(lat1) * cos(lat2) * sin((long2 - long1) / 2)**2))
  end

  def self.deg2rad(lat, long)
    [lat * PI / 180, long * PI / 180]
  end
end
