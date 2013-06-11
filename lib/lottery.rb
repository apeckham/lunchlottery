module Lottery
  def self.confirm_groups!
    Location.where(:day => one_day_from_today).each do |location|
      shuffled_people = location.people.subscribed.opted_in.all.shuffle

      if shuffled_people.length > 2
        groups = Grouper.make_groups(shuffled_people)
        total_people = location.people
        groups.each do |group|
          Notifier.confirm_groups(group, location, total_people, groups).deliver
        end
      end
    end
  end

  def self.invite_to_lunch!
    Person.subscribed.each do |person|
      if person.location.invite_day == Date.today.wday
        Notifier.invite_to_lunch(person).deliver
      end
    end
  end

  def self.one_day_from_today
    days_in_week = 7
    (Date.today.wday + 1) % days_in_week
  end
end