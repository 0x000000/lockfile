module LockFile
  class LockFile
    include TimeRules

    attr_accessor :path, :filename
    attr_reader :expire_after

    DEFAULT_OPTS = {
        :path => "/tmp",
        :filename => "lockfile.lock",
        :expire_after => nil
    }

    def initialize(opts)
      opts = DEFAULT_OPTS.merge opts
      @path, @filename, @expire_after = opts[:path], opts[:filename], opts[:expire_after]
    end

    def qualified_path
      File.join(@path, @filename)
    end

    def process_id
      locked? ? read_lockfile(self.qualified_path).strip.to_i : nil
    end

    def lock!
      locked? ? false : create_lockfile(self.qualified_path)
    end

    def unlock!
      unlocked? ? false : destroy_lockfile(self.qualified_path)
    end

    def locked?
      lockfile_exists?(self.qualified_path)
    end

    def unlocked?
      !lockfile_exists?(self.qualified_path)
    end

    def expired?
      return true unless @expire_after

      Time.now > expire_date
    end

    def creation_date
      File.mtime(qualified_path)
    end

    def expire_date
      calc_expire_date(creation_date, @expire_after) if @expire_after
    end

    protected

    def lockfile_exists?(file)
      File.exists?(file)
    end

    def create_lockfile(lockfile)
      File.open(lockfile, "w") { |f| f.write(Process.pid) }
    end

    def read_lockfile(lockfile)
      File.open(lockfile, "r").gets
    end

    def destroy_lockfile(lockfile)
      File.delete(lockfile)
    end
  end
end