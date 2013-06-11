class DailyCron

  def self.work
    Lottery.invite_to_lunch!
    Lottery.confirm_groups!
  end
end