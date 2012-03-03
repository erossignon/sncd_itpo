class DcnsOptiController < ApplicationController
  unloadable
  # include DcnsOptiHelper

  def index
    @features2 = Feature.all_by_level(2) .sort_by { |m| [ m.fixed_version_name ,m.done_ratio ]}
  end
  def show
    respond_to do |format|
      format.html { render }
      format.csv  { render }
    end
  end
end
