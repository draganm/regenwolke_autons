require 'structure_mapper'
require 'socket'

module RegenwolkeAutons

  class ApplicationAuton

    include StructureMapper::Hash

    attribute name: String

    attr_accessor :context

    def deploy(git_sha1)

    end

  end

  Nestene::Registry.register_auton(ApplicationAuton)
end


