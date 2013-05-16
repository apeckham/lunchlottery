class AddDayToLocations < ActiveRecord::Migration
  def self.up
    #  ISO-8601 standard, 0 is Sunday, 6 is Saturday
    add_column :locations, :day, :integer, default: 2
  end

  def self.down
    remove_column :locations, :day
  end
end
