require 'docker'

module RegenwolkeAutons

  class DeploymentAuton

    include StructureMapper::Hash

    attribute application_name: String
    attribute git_sha1: String
    # attribute

    attr_accessor :context

    def start(application_name, git_sha1)
      self.application_name = application_name
      self.git_sha1 = git_sha1
    end

    def terminate
      # TODO implement and test
    end


  end

  Nestene::Registry.register_auton(DeploymentAuton)
end


