require "issue"
require 'tracker'
class UserStory < Issue
  
  def UserStory.all()
       r = []
       features = f = Issue.find(:all,:conditions => [ "tracker_id = ?",$userstory_tracker.id]); 
       features.each do |issue|
         feature = issue.becomes(UserStory)
       end
       r 
  end
  def spec
      spec_id = 1
      l = CustomValue.find(:all,:conditions => [ "customized_id=? AND custom_field_id=?" ,self.id, spec_id])
      l.first.value
  end

end
