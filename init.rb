require 'redmine'

Redmine::Plugin.register :redmine_dcns_opti do
  name 'Redmine DCNS Opti plugin'
  author 'Etienne Rossignon - Euriware'
  description 'This is a plugin for Redmine'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://www.linkedin.com/in/etiennerossignon'
  
  require_dependency 'issue'
  require_dependency 'tracker'
   
  project_module :dcns_opti do 
     permission :dcns_opti, { :dcns_opti => [:index] }
  end
  
  menu :projet_menu, :dcns_opti, { :controller => 'dcns_opti', :action => :index } ,         :caption => :label_dcns_opti, :param => :project_id
  
end
