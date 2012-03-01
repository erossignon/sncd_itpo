#require "issue"
#require 'tracker'

$userstory_tracker = Tracker.find_by_name("user story")
class UserStory < Issue
  
  def UserStory.all()
    UserStory.find(:all,:conditions => [ "tracker_id = ?",$userstory_tracker.id])
  end

  def spec
      spec_id = 1
      l = CustomValue.find(:all,:conditions => [ "customized_id=? AND custom_field_id=?" ,self.id, spec_id])
      l.first.value
  end

end

