require 'fileutils'

describe LockFile::LockFile do

  let(:tmp_dirname) { File.expand_path(File.join(File.dirname(__FILE__), "..", "tmp")) }
  let(:fs_args) do
    {
        :path => tmp_dirname,
        :filename => "example.lock"
    }
  end

  let(:lockfile_path) { File.join(fs_args[:path], fs_args[:filename]) }
  let(:lockfile) { LockFile::LockFile.new(fs_args) }

  before :all do
    FileUtils.mkdir tmp_dirname
  end

  after :all do
    FileUtils.rm_r tmp_dirname
  end

  before :each do
    File.delete(lockfile_path) if File.exists?(lockfile_path)
  end

  it "should return a qualified pathname" do
    lockfile.path.should =~ /tmp/
    lockfile.filename.should == "example.lock"
    lockfile.qualified_path.should =~ /tmp\/example.lock/
  end

  it "should not initially be locked" do
    lockfile.locked?.should be_false
  end

  it "should be able to lock" do
    lockfile.lock!.should be_true
    lockfile.locked?.should be_true
    lockfile.unlocked?.should be_false
  end

  it "should be able to unlock" do
    lockfile.lock!.should be_true
    lockfile.locked?.should be_true
    lockfile.unlocked?.should be_false
    lockfile.unlock!.should be_true
    lockfile.locked?.should be_false
    lockfile.unlocked?.should be_true
  end

  it "should return the process ID of the lockfile if it exists" do
    lockfile.process_id.should be_nil
    lockfile.lock!
    lockfile.process_id.should_not be_nil
    lockfile.process_id.class.should == Fixnum
  end

  it 'should be never expire by default' do
    lockfile.expire_after.should be_nil
  end

  it 'should return expired? as false without :expire_at' do
    lockfile.expired?.should be_false
  end

  it 'should return expire_date as nil without :expire_at' do
    lockfile.expire_date.should be_nil
  end

  context "when expire_at is present" do
    let(:expired_lockfile) { LockFile::LockFile.new(fs_args.merge(:expire_after => "10 minutes")) }

    it 'should set correct expire args' do
      expired_lockfile.expire_after.should == "10 minutes"
    end

    it "should check file's creation time" do
      FileUtils.touch expired_lockfile.qualified_path
      expired_lockfile.creation_date.should <= Time.now
    end

    it 'should right calc expire date' do
      FileUtils.touch expired_lockfile.qualified_path
      expired_lockfile.expire_date.should >= Time.at(Time.now.to_i + 60 * 10)
    end

    it "should detect when file's creation time is expired'" do
      expired_lockfile.stub!(:creation_date).and_return(Time.at(Time.now - 60 * 9))
      expired_lockfile.expired?.should be_false

      expired_lockfile.lock!

      expired_lockfile.stub!(:creation_date).and_return(Time.at(Time.now - 60 * 11))
      expired_lockfile.expired?.should be_true
    end
  end
end
