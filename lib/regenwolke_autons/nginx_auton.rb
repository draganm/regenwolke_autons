require 'structure_mapper'
require 'childprocess'

module RegenwolkeAutons

  class NginxAuton

    include StructureMapper::Hash

    attribute stdout: String
    attribute stderr: String

    attr_accessor :context

    def start
      context.schedule_step(:start_nginx_if_not_running)
      context.schedule_repeating_delayed_step 10, 10, :start_nginx_if_not_running
    end

    def start_nginx
      create_config

      system('nginx','-t','-p', 'regenwolke/nginx', '-c', 'nginx.config') || raise("invalid nginx config")

      system('nginx','-p', 'regenwolke/nginx', '-c', 'nginx.config') || raise("error starting nginx")

    end

    def start_nginx_if_not_running
      context.schedule_step(:start_nginx) unless nginx_process_exist?
    end

    private

    def nginx_process_exist?
      unless File.exist?('nginx.pid')
        false
      else
        process_exist?(File.read('nginx.pid').to_i)
      end
    end

    def process_exist?(pid)
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
      File.write("regenwolke/nginx/nginx.config",erb.result(binding))
    end

  end

  Nestene::Registry.register_auton(NginxAuton)
end


