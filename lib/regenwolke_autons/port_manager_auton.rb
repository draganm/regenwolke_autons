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
      self.free_ports=(10_000 .. 10_000+50).to_a
      self.used_ports={}
    end

    def allocate_port(deployment_id)
      port = free_port.shift
      used_ports[deployment_id]=port
      port
    end

    def free_port(deployment_id)
      port = used_ports.delete(deployment_id)
      free_port << port
    end

  end

end


