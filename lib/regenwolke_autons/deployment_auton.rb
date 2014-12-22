require 'docker'

module RegenwolkeAutons

  class DeploymentAuton

    include StructureMapper::Hash

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
      container = Docker::Container.create('Image' => 'progrium/buildstep')
      self.container_id = container.id
      context.schedule_step(:notify_application)
    end

    def notify_application
    end

    def terminate
      # TODO implement and test
    end


  end

  Nestene::Registry.register_auton(DeploymentAuton)
end


