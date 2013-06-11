require 'spec_helper'

describe Notifier do
  describe ".invite" do
    before do
      @person = create_tuesday_lunch_person(:email => "foo@example.com")
      ActionMailer::Base.deliveries = []
    end

    it "sends the invitation email" do
      Notifier.invite_to_lunch(@person).deliver
      ActionMailer::Base.deliveries.length.should == 1

      message = ActionMailer::Base.deliveries.first
      message.subject.should =~ /Lunch on Tuesday\?/
      message.to.should == [@person.email]
      message.from.should == ["dine@lunchlottery.com"]
      message.body.to_s.should match /Hello/
      message.body.to_s.should include person_token_url(@person.authentication_token, :person => {:opt_in_datetime => @tuesday})
      message.body.to_s.should match /http:\/\/lunchlottery\.com\/people/
    end

    it "uses the locations day in the subject" do
      @person.location.day = 3
      Notifier.invite_to_lunch(@person).deliver

      message = ActionMailer::Base.deliveries.first
      message.subject.should =~ /Lunch on Wednesday\?/
    end
  end

  describe ".confirm" do
    before do
      @location = Location.new(:name => "mylocation", :meeting_point => "at the door")
      @total_people = new_people(8, @location)
      @people = @total_people[0..4]
      @groups = [@people[0..2], @people[3..4], @people[3..4]]

      Notifier.confirm_groups(@people, @location, @total_people, @groups).deliver
      ActionMailer::Base.deliveries.length.should == 1

      @message = ActionMailer::Base.deliveries.first
    end

    it "sends the confirmation email" do
      @message.subject.should =~ /Your lunch tomorrow/
      @message.to.should == @people.collect(&:email)
      @message.from.should == ["dine@lunchlottery.com"]
      @message.body.to_s.should match /Hello/
      @message.body.to_s.should match /gravatar/
      @message.body.to_s.should match /at the door/
    end

    it 'should include a calculation of the number of people opted in' do
      @message.body.to_s.should match /7\s*people/
    end

    it 'should include the total number of people at the location' do
      @message.body.to_s.should match /of\s*#{@total_people.size}/
    end

    it 'should show the stats about the groups' do
      @message.body.to_s.gsub(/\s+/, ' ').should include "2 groups of 2 people"
      @message.body.to_s.gsub(/\s+/, ' ').should include "1 group of 3 people"
    end
  end
end