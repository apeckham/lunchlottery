require 'spec_helper'

describe Lottery do
  describe ".confirm_groups!" do
    context "with groups" do
      before do
        tuesday = 2
        wednesday = 3
        @pivotal = Location.create!(:name => "pivotal", :address => "731 Market Street San Francisco, CA", :day => tuesday)
        @pivotal_people = new_people(7, @pivotal, "2100-11-02 23:59")
        @pivotal_people.first.opt_in_datetime = nil
        @pivotal_people.each(&:save!)

        @storek = Location.create!(:name => "storek", :address => "149 9th Street San Francisco, CA", :day => tuesday)
        @storek_people = new_people(3, @storek, "2100-11-02 23:59")
        @storek_people.each(&:save!)

        @substantial = Location.create!(:name => "substantial", :address => "900 E Pine St, Seattle, WA", :day => wednesday)
        @substantial_people = new_people(3, @substantial, "2100-11-02 23:59")
        @substantial_people.each(&:save!)
      end

      context "when it is tuesday" do
        before do
          tuesday = Time.zone.parse("2013-5-14 1:11:11")

          Timecop.freeze(tuesday) do
            Lottery.confirm_groups!
          end
        end

        it "confirms groups of opted-in tuesday people" do
          (ActionMailer::Base.deliveries[0].to + ActionMailer::Base.deliveries[1].to).should =~ %w[
          pivotal_2@example.com pivotal_3@example.com pivotal_4@example.com
          pivotal_5@example.com pivotal_6@example.com pivotal_7@example.com
        ]

          ActionMailer::Base.deliveries[2].to.to_a.should =~ %w[
          storek_1@example.com storek_2@example.com storek_3@example.com
        ]
        end

        it "does not reset the opt-in flag yet" do
          Person.opted_in.length.should == 12
        end
      end

      it "does not send confirmations to those who have unsubscribed" do
        @storek = Location.create!(:name => "storek", :address => "149 9th Street San Francisco, CA")

        create_tuesday_lunch_person(:email => "quuxNope@example.com", :subscribed => false, :opt_in_datetime => "2100-11-02 23:59", :location => @storek)
        create_tuesday_lunch_person(:email => "quux1@example.com", :subscribed => true, :opt_in_datetime => "2100-11-02 23:59", :location => @storek)
        create_tuesday_lunch_person(:email => "quux2@example.com", :subscribed => true, :opt_in_datetime => "2100-11-02 23:59", :location => @storek)
        create_tuesday_lunch_person(:email => "quux3@example.com", :subscribed => true, :opt_in_datetime => "2100-11-02 23:59", :location => @storek)
        Lottery.confirm_groups!
        group_mail_deliveries = ActionMailer::Base.deliveries
        grouped_emails = group_mail_deliveries.map(&:to)
        grouped_emails.flatten.should_not include("quuxNope@example.com")
      end
    end
  end


  it "doesn't send a confirmation if a group has less than 3 people" do
    location = Location.create!(:name => "yelp", :address => "1 Market Street", :day => 2)
    new_people(2, location, "2100-11-02 23:59").each(&:save!)

    Lottery.confirm_groups!
    ActionMailer::Base.deliveries.should be_empty
  end

  describe ".invite_to_lunch!" do
    before do
      create_tuesday_lunch_person(:email => "footuesday@example.com")
      create_tuesday_lunch_person(:email => "foo2tuesday@example.com", :opt_in_datetime => nil)
      create_wednesday_lunch_person(:email => "foowednesday@example.com")
      create_wednesday_lunch_person(:email => "foo2wednesday@example.com", :opt_in_datetime => nil)
      @monday = Time.zone.parse("2013-5-13 1:11:11")
    end

    it "sends the invite on monday to the wednesday people" do
      Timecop.freeze(@monday) do
        Lottery.invite_to_lunch!
      end
      Person.count.should == 4
      ActionMailer::Base.deliveries.length.should == 2
      ActionMailer::Base.deliveries.first.to.should == ["foowednesday@example.com"]
      ActionMailer::Base.deliveries.last.to.should == ["foo2wednesday@example.com"]
    end

    it "does not send invite to those who have unsubscribed" do
      Person.delete_all
      create_tuesday_lunch_person(:email => "quux@example.com", :subscribed => false)
      create_wednesday_lunch_person(:email => "blamowed@example.com", :subscribed => false)

      Timecop.freeze(@monday) do
        Lottery.invite_to_lunch!
      end

      ActionMailer::Base.deliveries.length.should == 0
    end
  end
end