require 'fileutils'

module RedisTestSetup

  APP_ROOT = File.expand_path(File.join(File.dirname(__FILE__), "..", ".."))

  def self.start_redis!(env)
    dir_temp = File.expand_path(File.join(APP_ROOT, 'tmp'))
    dir_conf = File.expand_path(File.join(APP_ROOT, 'config'))
    ::FileUtils.mkdir_p(dir_temp)
    self.cleanup(dir_temp, env)
    Dir.chdir(APP_ROOT) do
      system("redis-server #{dir_conf}/redis-#{env}.conf") or raise('unable to launch redis-server')
    end
    Kernel.at_exit do
      if (pid = `cat #{dir_temp}/redis-#{env}.pid`.strip) =~ /^\d+$/
        Process.kill("QUIT", pid.to_i)
        self.cleanup(dir_temp, env)
      end
    end
  end

  def self.cleanup(dir_temp, env)
    `rm -f #{dir_temp}/redis-#{env}-dump.rdb`
    `rm -f #{dir_temp}/redis-#{env}.pid`
  end
end
