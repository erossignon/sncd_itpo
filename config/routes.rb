ActionController::Routing::Routes.draw do |map|
  map.connect 'dcns_opti/:project_id',:controller => :dcns_opti,:action => 'show', :format => 'html'
end
