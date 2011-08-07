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
  
end
