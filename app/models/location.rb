 class Location < ActiveRecord::Base
  has_many :people
  has_many :location_restaurants
  has_many :restaurants, :through => :location_restaurants
  validates_presence_of :address

  geocoded_by :address
  after_validation :geocode, :if => :address_changed?

  def to_param
    name
  end

  def reminder_day
    days_in_week = 7
    (day - 1) % days_in_week
  end
end
