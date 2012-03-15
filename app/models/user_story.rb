#require "issue"
#require 'tracker'

$userstory_tracker = Tracker.find_by_name("User story")
class UserStory < Issue
  
  def UserStory.all(project_id)
    UserStory.find(:all,:conditions => [ "tracker_id = ? AND project_id = ?",$userstory_tracker.id , project_id])
  end

  def spec
      spec_id = 1
      l = CustomValue.find(:all,:conditions => [ "customized_id=? AND custom_field_id=?" ,self.id, spec_id])
      l.first.value
  end
  def parent_feature
     issues = Feature.extractLinkFeature(self)
     res = []
     issues.each do |issue|
       if issue.tracker == $feature_tracker then
          feature = issue.becomes(Feature)
          res << feature
       end
     end
     assert { res.size() == 1 }
     res[0]
  end
end

