class DcnsOptiController < ApplicationController
  unloadable
  # include DcnsOptiHelper

  def index
    @project   = Project.find(params[:project_id])
    @features2 = Feature.all_by_level(2,@project.id) .sort_by { |m| [ m.fixed_version_name ,m.done_ratio ]}
  end

  def show

    @project  = Project.find(params[:project_id])
    respond_to do |format|
      format.html { render }
      format.csv  { render }
    end
  end
end
