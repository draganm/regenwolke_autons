require 'nestene'
require 'regenwolke_autons/regenwolke_auton'
require 'regenwolke_autons/nginx_auton'
require "regenwolke_autons/version"


module RegenwolkeAutons

  class Core
    def self.init

      Dir.mkdir('regenwolke/nginx') unless File.exists?('regenwolke/nginx')

      unless Celluloid::Actor[:nestene_core].auton_names.include?('nginx')
        Celluloid::Actor[:nestene_core].create_auton('RegenwolkeAutons::NginxAuton','nginx')
        Celluloid::Actor[:nestene_core].schedule_step('nginx', 'start')
      end
    end
  end

end
