require 'spec_helper'

describe Notifier do
  describe ".send_reminders" do
    before do
      @people = %w(
                              1@example.com
                              2@example.com
                              3@example.com
                              4@example.com
                              5@example.com
                              6@example.com
                              7@example.com
                              8@example.com
                            )

      Person.stub(:all_emails) { @people }
    end

    after do
      ActionMailer::Base.deliveries = []
    end

    context "when it's Monday" do
      before do
        monday = Date.parse("2011-03-21")

        Date.stub(:today) { monday }
      end

      it "should send 2 emails to 8 people, in groups of 4" do
        Notifier.send_reminders

        ActionMailer::Base.deliveries.length.should == 2
        ActionMailer::Base.deliveries[0].to.length.should == 4
        ActionMailer::Base.deliveries[1].to.length.should == 4
      end

      it "should shuffle the people" do
        @people.should_receive(:shuffle!)
        Notifier.send_reminders
      end

      context "when one person would dine alone" do
        before do
          @people = %w(
                              1@example.com
                              2@example.com
                              3@example.com
                              4@example.com
                              5@example.com
                            )
        end

        it "should split up the groups more evenly" do
          Notifier.send_reminders

          ActionMailer::Base.deliveries.length.should == 2
          ActionMailer::Base.deliveries[0].to.length.should == 3
          ActionMailer::Base.deliveries[1].to.length.should == 2
        end
      end

      context "when two people would dine alone" do
        before do
          @people = %w(
                              1@example.com
                              2@example.com
                              3@example.com
                              4@example.com
                              5@example.com
                              6@example.com
                            )
        end

        it "should split up the groups evenly" do
          Notifier.send_reminders

          ActionMailer::Base.deliveries.length.should == 2
          ActionMailer::Base.deliveries[0].to.length.should == 3
          ActionMailer::Base.deliveries[1].to.length.should == 3
        end
      end
    end

    context "when it's not Monday" do
      before do
        wednesday = Date.parse("2011-03-30")
        Date.stub(:today) { wednesday }
      end

      it "should only send emails on Monday" do
        Notifier.send_reminders
        ActionMailer::Base.deliveries.length.should == 0
      end
    end
  end
end
