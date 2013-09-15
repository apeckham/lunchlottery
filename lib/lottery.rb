module Lottery
  def self.confirm_groups!
    Location.where(:day => Time.zone.today.wday).each do |location|
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
      if person.location.invite_day == Time.zone.today.wday
        Notifier.invite_to_lunch(person).deliver
      end
    end
  end
end