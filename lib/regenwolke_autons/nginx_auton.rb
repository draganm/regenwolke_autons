require 'structure_mapper'
require 'childprocess'

module RegenwolkeAutons

  class NginxAuton

    include StructureMapper::Hash

    attribute pid: Fixnum
    attribute stdout: String
    attribute stderr: String

    attr_accessor :context

    def start
      context.schedule_step(:start_nginx_if_not_running)
      context.schedule_repeating_delayed_step 10, 10, :start_nginx_if_not_running
    end

    def start_nginx
      create_config

      cp = ChildProcess.build('nginx', '-p', '.', '-c', 'nginx.config')
      cp.detach = true
      cp.start
      self.pid =  cp.pid
    end

    def start_nginx_if_not_running
      context.schedule_step(:start_nginx) unless nginx_process_exist?
    end

    private

    def nginx_process_exist?
      if pid
        begin
          Process.getpgid( pid )
          true
        rescue Errno::ESRCH
          false
        end
      else
        false
      end
    end

    def create_config
      applications={'regenwolke' => [['localhost',ENV['PORT'] || 5000]]}
      erb = ERB.new File.read(File.expand_path('../nginx_config.erb', __FILE__))
      File.write("nginx.config",erb.result(binding))
    end

  end

  Nestene::Registry.register_auton(NginxAuton)
end


