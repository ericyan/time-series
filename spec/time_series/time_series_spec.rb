require 'spec_helper'

describe TimeSeries do
  let(:data_points) do
    data_points = {
      Time.at(2000000000) => "The second Unix billennium",
      Time.at(1234567890) => "Let's go party",
      Time.at(1000000000) => "The first Unix billennium",
      Time.at(2147485547) => "Year 2038 problem"
    }
    data_points.keys.zip(data_points.values).collect { |dp| DataPoint.new(dp[0], dp[1]) }
  end
  let(:time_series) { TimeSeries.new(data_points) }

  describe "#new" do
    it "takes a array of DataPoints" do
      time_series.length.should eql 4
    end

    it "takes a array of timestamps and a array of data" do
      data_points = time_series.data_points
      time_series = TimeSeries.new(data_points.keys, data_points.values)
      time_series.length.should eql 4
    end
  end

  describe "#<<" do
    it "adds a new data point" do
      time_series << DataPoint.new(Time.now, "Knock knock")
      time_series.length.should eql 5
    end

    it "update the existing data point" do
      time_series << DataPoint.new(Time.at(1234567890), 'PARTY TIME!')
      time_series.length.should eql 4
      time_series.at(Time.at(1234567890)).data.should eql 'PARTY TIME!'
    end
  end

  describe "#at" do
    it "returns data associated with the given timestamp" do
      time_series.at(Time.at(1000000000)).data.should eql "The first Unix billennium"
    end

    it "returns data in array if two or more timestamps are given" do
      time_series.at(Time.at(1000000000), Time.at(2000000000))
        .collect { |data_point| data_point.data }.should
        eql(["The first Unix billennium", "The second Unix billennium"])
    end
  end

  describe "#slice" do
    it "returns all data points in the given timeframe" do
      ts = time_series.slice from: Time.at(1000000000), to: Time.at(2000000000)
      ts.length.should eql 3
      ts.at(Time.at 2147485547).should eql nil
    end

    it "returns all data points after the from time" do
      ts = time_series.slice from: Time.at(2000000000)
      ts.length.should eql 2
      ts.at(Time.at(1000000000), Time.at(1234567890)).should eql [nil, nil]
    end

    it "returns all data points before the to time" do
      ts = time_series.slice to: Time.at(1234567890)
      ts.length.should eql 2
      ts.at(Time.at(2000000000), Time.at(2147485547)).should eql [nil, nil]
    end
  end

  describe "is enumerable" do
    it "returns the first data point(s) according to its timestamp" do
      time_series.first.data.should eql "The first Unix billennium"
      time_series.first(2).collect { |data_point| data_point.data }.should
        eql ["The first Unix billennium", "Let's go party"]
    end

    it "returns the last data point(s) according to its timestamp" do
      time_series.last.data.should eql "Year 2038 problem"
      time_series.last(2).collect { |data_point| data_point.data }.should
        eql ["The second Unix billennium", "Year 2038 problem"]
    end
  end

  describe "#to_a" do
    it "returns a array of sorted DataPoints" do
      time_series.to_a.should be_a_kind_of Array
      time_series.to_a.should eql data_points.sort
    end
  end
end
