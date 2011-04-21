require 'spec_helper'

describe Notifier do
  describe ".invite" do
    before do
      @people = stub_people
      Notifier.invite(@people).deliver
    end

    it "send the invite email" do
      ActionMailer::Base.deliveries.length.should == 1

      message = ActionMailer::Base.deliveries.first
      message.subject.should =~ /Your lunch tomorrow/
      message.to.should == @people.collect(&:email)
      message.from.should == ["dine@lunchlottery.com"]
      message.body.to_s.should match /Hello/
    end
  end

  describe ".remind" do
    before do
      @person = Person.new(:email => "e@mail.com")
      Notifier.remind(@person).deliver
    end
    
    it "sends the remind email" do
      ActionMailer::Base.deliveries.length.should == 1

      message = ActionMailer::Base.deliveries.first
      message.subject.should =~ /Lunch on Tuesday?/
      message.to.should == [@person.email]
      message.from.should == ["dine@lunchlottery.com"]
      message.body.to_s.should match /Hello/
    end
  end

end