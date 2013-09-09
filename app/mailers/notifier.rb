class Notifier < ActionMailer::Base
  def confirm_groups(people, location, total_people, groups)
    @people = people
    @location = location
    @opted_in_count = groups.inject(0) { |sum, group| sum + group.size }
    @total_people = total_people
    @group_stats = group_stats(groups)
    mail(:to => @people.map(&:email),
         :subject => "Your lunch today",
         :from => "dine@lunchlottery.com")
  end

  def invite_to_lunch(person)
    @person = person
    day = person.location.try(:day)
    @day_name = Date::DAYNAMES[day]
    mail(:to => @person.email,
      :subject => "Lunch on #{@day_name}?",
      :from => "dine@lunchlottery.com")
  end

  def group_stats groups
    groups.reduce({}) do |stats, group|
      stats[group.size] ||= 0
      stats[group.size] += 1
      stats
    end
  end
end