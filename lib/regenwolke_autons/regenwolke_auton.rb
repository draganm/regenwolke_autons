require 'structure_mapper'

module RegenwolkeAutons

  class RegenwolkeAuton
    include StructureMapper::Hash


    attribute test: String
  end

  Nestene::Registry.register_auton(RegenwolkeAuton)
end


