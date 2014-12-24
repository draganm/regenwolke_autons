require 'structure_mapper'
require 'socket'

module RegenwolkeAutons

  class NginxAuton < Nestene::Auton

    attribute endpoints: {String => Fixnum}
    attribute stderr: String

    attr_accessor :context

    def start
      context.schedule_step(:start_nginx_if_not_running)
      context.schedule_repeating_delayed_step 90, 90, :start_nginx_if_not_running
      self.endpoints = {}
    end

    def start_nginx
      create_config

      system('nginx','-t','-p', 'regenwolke/nginx', '-c', 'nginx.config') || raise("Invalid nginx config")

      system('nginx','-p', 'regenwolke/nginx', '-c', 'nginx.config') || raise("Could not start nginx")

      wait_for_nginx

    end

    def update_endpoints new_endpoints
      self.endpoints.merge!(new_endpoints)
      context.schedule_step(:reconfigure_nginx)
    end


    def reconfigure_nginx
    end

    def start_nginx_if_not_running
      context.schedule_step(:start_nginx) unless nginx_running?
    end

    private

    def nginx_running?
      socket = TCPSocket.new "localhost", 9080
      socket.close
      true
    rescue Errno::ECONNREFUSED
      false
    end

    def wait_for_nginx
      (1..20).each do
        return if nginx_running?
        sleep 0.1
      end
      raise "nginx didn't start within 20 seconds"
    end

    def create_config
      applications={'regenwolke' => [['localhost',ENV['PORT'] || 5000]]}
      erb = ERB.new File.read(File.expand_path('../nginx_config.erb', __FILE__))
      File.write("regenwolke/nginx/nginx.config",erb.result(binding))
    end

  end

end


