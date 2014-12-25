require 'docker'

module RegenwolkeAutons

  class DeploymentAuton < Nestene::Auton

    attribute application_name: String
    attribute git_sha1: String
    attribute port: Fixnum
    attribute container_id: String

    attr_accessor :context

    def start(application_name, git_sha1)
      self.application_name = application_name
      self.git_sha1 = git_sha1
      context.schedule_step(:request_port)
    end

    def request_port
      context.schedule_step_on_auton('port_manager',:request_port, [context.auton_id, :use_port])
    end

    def use_port port
      self.port = port
      context.schedule_step(:start_container)
    end

    def start_container
      # TODO extract creation of container config to a method and thorroughly test it
      container = Docker::Container.create(
        'Image' => 'dmilhdef/buildstep',
        'Cmd' => [
          '/bin/bash',
          '-c',
          'useradd runner && cd / && tar xf /app.tar && /start web'
        ],
        "Env" => [
          "PORT=5000"
        ],
        "ExposedPorts" => {
          "5000/tcp" => {}
        },
        "HostConfig" => {
          "Binds" => [
            "/regenwolke/capsules/#{self.application_name}-#{self.git_sha1}.tar:/app.tar:ro"
          ],
          "PortBindings" => {
            "5000/tcp" => [
              {
                "HostIp" => "",
                "HostPort" => self.port.to_s
              }
            ]
          }
        }
      )
      container.start
      self.container_id = container.id
      context.schedule_step(:notify_application)
    end

    def notify_application
      application_auton_id = "application:%s" % application_name
      context.schedule_step_on_auton(application_auton_id, :deployment_complete, [self.git_sha1, self.port])
    end

    def terminate
      container = Docker::Container.get(self.container_id)
      container.delete(:force => true)
      context.schedule_step_on_auton('port_manager',:release_port, [context.auton_id, self.port])
      context.terminate
    end


  end

end


