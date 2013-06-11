require 'spec_helper'

describe DailyCron do
  describe ".work" do
    it "sends reminders daily" do
      Lottery.should_receive(:invite_to_lunch!)
      DailyCron.work
    end

    it "sends invitations daily" do
      Lottery.should_receive(:confirm_groups!)
      DailyCron.work
    end
  end
end