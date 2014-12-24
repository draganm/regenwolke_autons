require 'structure_mapper'
require 'socket'

module RegenwolkeAutons

  class CurrentDeployment
    include StructureMapper::Hash
    attribute git_sha1: String
    attribute port: Fixnum
  end

  class ApplicationAuton < Nestene::Auton

    attribute application_name: String

    attribute current_deployment: CurrentDeployment

    attr_accessor :context


    def start(application_name)
      self.application_name = application_name
    end

    def deploy(git_sha1)
      deployment_name = "deployment:%s:%s" % [application_name, git_sha1]
      context.create_auton 'RegenwolkeAutons::DeploymentAuton', deployment_name
      context.schedule_step_on_auton deployment_name, :start, [application_name, git_sha1]
    end


    def deployment_complete(git_sha1, port)

      context.schedule_step_on_auton 'nginx', :update_endpoints, [{application_name => port}]

      if current_deployment
        deployment_name = "deployment:%s:%s" % [application_name, current_deployment.git_sha1]
        context.schedule_step_on_auton deployment_name, :terminate
      end

      self.current_deployment = CurrentDeployment.new
      self.current_deployment.git_sha1 = git_sha1
      self.current_deployment.port = port

    end

  end

end


