class Dates
  def self.lunch_day?(date, lunch_day)
    date.wday == lunch_day
  end

  def self.next_lunch_day(lunch_day)
    now = Time.zone.now.to_date
    now = now.next until lunch_day?(now, lunch_day)
    now + 1.day - 1.second
  end
end