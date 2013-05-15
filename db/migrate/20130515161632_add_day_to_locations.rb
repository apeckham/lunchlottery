class AddDayToLocations < ActiveRecord::Migration
  def self.up
    #  ISO-8601 standard, 1 is Monday, 7 is Sunday
    add_column :locations, :day, :integer, default: 2
  end

  def self.down
    remove_column :locations, :day
  end
end
