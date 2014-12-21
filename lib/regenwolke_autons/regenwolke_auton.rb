require 'structure_mapper'

module RegenwolkeAutons

  class RegenwolkeAuton
    include StructureMapper::Hash

    attr_accessor :context

    def initialize
      self.applications = []
    end

    def deploy_application(name, git_sha)

      unless applications.include?(name)
        context.create_auton 'RegenwolkeAutons::ApplicationAuton', application_auton_name(name)
      end

      context.schedule_step(application_auton_name(name),:deploy,[git_sha])


    end

    attribute applications: [String]


    private

    def application_auton_name(application_name)
      'application:%s' % application_name
    end

  end

  Nestene::Registry.register_auton(RegenwolkeAuton)
end


