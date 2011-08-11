require 'fileutils'

describe LockFile::TimeRules do

  class Dummy
    include LockFile::TimeRules
  end

  let(:dummy) { Dummy.new }

  context "with minute strings" do

    it 'should correct parse them' do
      dummy.parse_time("1 minute").should == 1
      dummy.parse_time("10 minutes").should == 10
      dummy.parse_time("123 minutes").should == 123
      dummy.parse_time("0 minutes").should == 0
    end
  end

  context 'with hour strings' do

    it 'should correct parse them' do
      dummy.parse_time("1 hour").should == 1 * 60
      dummy.parse_time("3 hours").should == 3 * 60
      dummy.parse_time("10 hours").should == 10 * 60
      dummy.parse_time("0 hours").should == 0
    end
  end

  context 'with complex strings' do

    it 'should correct parse them' do
      dummy.parse_time("1 hour and 30 minutes").should == 1 * 60 + 30
      dummy.parse_time("3 hours and 1 minute").should == 3 * 60 + 1
      dummy.parse_time("10 hours and 14 minutes").should == 10 * 60 + 14
      dummy.parse_time("4 hours and 0 minutes").should == 4 * 60
    end
  end

  it 'should make new time' do

    [10, 1, 61, 0, 444].each do |min|
      old_time, new_time = [Time.now, dummy.calc_expire_date(Time.now, "#{min} minutes")]

      (old_time.to_i / 60 + min).should <= (new_time.to_i)
    end
  end

end