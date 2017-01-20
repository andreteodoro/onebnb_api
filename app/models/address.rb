class Address < ApplicationRecord
  # Get the geocode after validating the data
  after_validation :geocode

  geocoded_by :full_address do |obj, results|
    if geo = results.first
      obj.latitude = geo.latitude
      obj.longitude = geo.longitude
    end
  end

  def full_address
    "#{street}, #{neighborhood}, #{city} #{number}, #{country}"
  end
end
