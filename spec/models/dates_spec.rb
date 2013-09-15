require 'spec_helper'

describe Dates do
  describe "#next_lunch_day" do
    it "works a while ago" do
      Timecop.freeze(Time.zone.parse("2008-11-10 11:11:11")) do
        Dates.next_lunch_day(2).should == Time.zone.parse("2008-11-11 23:59:59")
      end
    end

    it "should return next tuesday for 2" do
      Timecop.freeze(Time.zone.parse("2011-11-11 11:11:11")) do
        Dates.next_lunch_day(2).should == Time.zone.parse("2011-11-15 23:59:59")
      end
    end

    it "should return next wednesday for 3" do
      Timecop.freeze(Time.zone.parse("2011-11-11 11:11:11")) do
        Dates.next_lunch_day(3).should == Time.zone.parse("2011-11-16 23:59:59")
      end
    end

    it "works when called on a tuesday" do
      Timecop.freeze(Time.zone.parse("2011-11-15 11:11:11")) do
        Dates.next_lunch_day(2).should == Time.zone.parse("2011-11-15 23:59:59")
      end
    end

    it "works when called on a wednesday" do
      Timecop.freeze(Time.zone.parse("2011-11-09 11:11:11")) do
        Dates.next_lunch_day(2).should == Time.zone.parse("2011-11-15 23:59:59")
      end
    end

    it "works when called right before midnight" do
      Timecop.freeze(Time.zone.parse("2011-11-08 23:58:59")) do
        Dates.next_lunch_day(2).should == Time.zone.parse("2011-11-08 23:59:59")
      end
    end

    it "should stringify to an utc ISO 8601 date for emails and form values" do
      Timecop.freeze(Time.zone.parse("2011-11-08 23:58:59")) do
        Dates.next_lunch_day(2).utc.iso8601.should == "2011-11-09T05:59:59Z"
      end
    end
  end
end