require 'structure_mapper'
require 'socket'

module RegenwolkeAutons

  class PortManagerAuton < Nestene::Auton

    attribute free_ports: [Fixnum]
    attribute used_ports: {Fixnum => String}

    attr_accessor :context

    def initialize
      self.free_ports=[]
      self.used_ports={}
    end

    def start
      self.free_ports=(10_000 ... 10_000+50).to_a
      self.used_ports={}
    end

    def request_port(auton_id, method_name)
      port = allocate_port(auton_id)
      context.schedule_step_on_auton(auton_id, method_name, [port])
    end

    private

    def allocate_port(auton_id)
      port = free_ports.shift
      used_ports[auton_id]=port
      port
    end

    def free_port(auton_id)
      port = used_ports.delete(auton_id)
      free_ports << port
    end

  end

end


