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
      context.schedule_step(:start_nginx)
    end

    def start_nginx
      create_config

      nginx_binary = File.exist?('/usr/sbin/nginx') ? '/usr/sbin/nginx' : 'nginx'

      cp = ChildProcess.build(nginx_binary, '-p', '.', '-c', 'nginx.config')
      cp.detach = true
      cp.start
      self.pid =  cp.pid
    end

    def check_process
      context.schedule_step(:start_nginx) unless nginx_process_exist?
    end

    private

    def nginx_process_exist?
      begin
        Process.getpgid( pid )
        true
      rescue Errno::ESRCH
        false
      end
    end

    def create_config
      applications={'regenwolke' => ['localhost',[ENV['PORT'] || 5000]]}
      erb = ERB.new File.read(File.expand_path('../nginx_config.erb', __FILE__))
      File.write("nginx.config",erb.result(binding))
    end

  end

  Nestene::Registry.register_auton(NginxAuton)
end


