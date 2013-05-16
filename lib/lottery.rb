module Lottery
  def self.send_invitations!
    Location.where(day: days_out(2)).each do |location|
      shuffled_people = location.people.subscribed.opted_in.all.shuffle

      if shuffled_people.length > 2
        groups = Grouper.make_groups(shuffled_people)
        total_people = location.people
        groups.each do |group|
          Notifier.invite(group, location, total_people, groups).deliver
        end
      end
    end
  end

  def self.send_reminders!
    Person.subscribed.each do |person|
      if person.location.reminder_day == Date.today.wday
        Notifier.remind(person).deliver
      end
    end
  end

  def self.days_out num
    days_in_week = 7
    (Date.today.wday + num) % days_in_week
  end
end