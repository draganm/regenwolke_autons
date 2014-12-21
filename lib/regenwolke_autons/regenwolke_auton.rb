require 'structure_mapper'

module RegenwolkeAutons

  class RegenwolkeAuton
    include StructureMapper::Hash
    attribute applications: [String]


    attr_accessor :context

    def initialize
      self.applications = []
    end

    def start
      context.create_auton('RegenwolkeAutons::NginxAuton', 'nginx')
      context.schedule_step('nginx', :start)

      context.create_auton('RegenwolkeAutons::PortManagerAuton', 'port_manager')
      context.schedule_step('port_manager', :start)
    end

    def deploy_application(name, git_sha)

      unless applications.include?(name)
        context.create_auton 'RegenwolkeAutons::ApplicationAuton', application_auton_name(name)
      end

      context.schedule_step(application_auton_name(name),:deploy,[git_sha])


    end




    private

    def application_auton_name(application_name)
      'application:%s' % application_name
    end

  end

  Nestene::Registry.register_auton(RegenwolkeAuton)
end


