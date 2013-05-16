require 'spec_helper'

describe DailyCron do
  describe ".work" do
    it "sends reminders daily" do
      Lottery.should_receive(:send_reminders!)
      DailyCron.work
    end

    it "sends invitations daily" do
      Lottery.should_receive(:send_invitations!)
      DailyCron.work
    end
  end
end