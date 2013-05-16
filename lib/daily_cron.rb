class DailyCron

  def self.work
    Lottery.send_reminders!
    Lottery.send_invitations!
  end
end