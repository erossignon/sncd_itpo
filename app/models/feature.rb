


$feature_tracker   = Tracker.find_by_name("Feature")
$userstory_tracker = Tracker.find_by_name("user story")
$nouveau_status    = IssueStatus.find_by_name("Nouveau")
$encours_status    = IssueStatus.find_by_name("En Cours")
$closed_status     = IssueStatus.find_by_name("Terminé")


 class Feature  < Issue
       # extract usefull tracker

     def Feature.all_by_level(level)
         r = []
         features = f = Issue.find(:all,:conditions => [ "tracker_id = ?",$feature_tracker.id],   \
                            :include => [ :tracker , :fixed_version,:status ,:relations_from , :relations_to ]); true
         features.each do |issue|
           feature = issue.becomes(Feature)
           if feature.level == level then
             r << feature
           end
         end
         r 
     end
     def level
         niveau_id = 4
         l = CustomValue.find(:all,:conditions => [ "customized_id=? AND custom_field_id=?" ,self.id, niveau_id])
         if l.size == 0 then
           return "NOLEVEL"
         end
         l.first.value.to_i
     end
     def spec
         spec_id = 1
         l = CustomValue.find(:all,:conditions => [ "customized_id=? AND custom_field_id=?" ,self.id, spec_id])
         l.first.value
     end

     # return the estimated featuresize 
     def featuresize()
       if self.story_points == nil 
          self.estimated_hours
       else
          self.story_points
       end
     end

   
     def Feature.extractLinkFeature(f)
       rel = []
       r1 = IssueRelation.find(:all,:conditions => ["issue_from_id = ? ", f.id])
       r1.each do |r|  
          rel << r.issue_to_id 
       end
       # certaines features ont pu être associées à l'envers
       r2 = IssueRelation.find(:all,:conditions => ["issue_to_id = ? ", f.id])
       r2.each do |r|
         rel << r.issue_from_id 
       end
       result = []
       rel.each do |r|
         issue = Issue.find(r, :include => [ :tracker , :fixed_version,:status ,:relations_from , :relations_to ] )
         if issue.tracker == $userstory_tracker then
              result << issue.becomes(UserStory)
         end
         if ( issue.tracker == $feature_tracker) then
            result << issue.becomes(Feature)
         end
       end
       result
     end 

     def parent_feature
        assert{ level == 3}
        issues = Feature.extractLinkFeature(self)
        res = []
        issues.each do |issue| 
          if issue.tracker == $feature_tracker then
             feature = issue.becomes(Feature)
             if (feature.level == 2) then
                res << feature
             end
          end
        end
        assert { res.size() == 1 }
        res[0]
     end
     # extraire les features de niveau 3 liées à une feature de niveau 2
     def sub_features()      
        l = self.level
        issues = Feature.extractLinkFeature(self)
        res = []
        issues.each do |issue| 
          if issue.tracker == $feature_tracker then
             if (issue.level == l+1) then
                res << issue
             end
          end
        end
        res
     end
     def userstories()
        issues = Feature.extractLinkFeature(self)
        res = []
        issues.each do |issue| 
          if issue.tracker == $userstory_tracker then
             res << issue
          end
        end
        res
      
     end

     # calcul la taille réelle estimée par l'équipe de la feature
     # en la basant sur la taille des user stories 
     #  
     def actualsize()
       sum = 0
       sub_features.each do |sf| 
          sum+=sf.actualsize()
       end
       userstories.each do |us|
          sum+=us.story_points if us.story_points != nil
       end
       sum
     end
   
     def calculated_percent_done() 
       weight = 0
       sum    =0
       sub_features.each do |sf| 
          sf.userstories.each do |us|
             if us.story_points != nil then
                weight+=us.story_points
                sum   +=us.story_points*us.done_ratio
             end
          end
       end
       userstories.each do |us|
         if us.story_points != nil then
           weight+=us.story_points
           sum   +=us.story_points*us.done_ratio
         end 
       end
       res = 0
       res = sum/weight  if weight > 0
       res.to_i
     end

     def sortable_effective_date
      return self.fixed_version.effective_date if self.fixed_version != nil
      return DateTime.new(2016,1,1)
     end
     def is_in_scope?
       return false if self.fixed_version == nil
       return false if self.fixed_version.effective_date > DateTime.new(2012,7,1)

        # ne contient pas de V dans le nom du sprint ( type Hors VA+ ou VA+)
       return true if  (( self.fixed_version.name =~ /V/ ) == nil )

       false
     end
     def fixed_version_name
       return "non planifié" if self.fixed_version == nil
       fixed_version.name
     end
     def Feature.update_feature(feat)

       feat.reload # for some reason, needed
       actual_done = feat.calculated_percent_done
       if actual_done != feat.done_ratio then
          puts "Updating feature #{feat.id} #{feat.spec} advancement from #{feat.done_ratio} to #{actual_done}"
          feat.done_ratio = actual_done
          feat.save(true)
       end
       if ( feat.done_ratio == 100  and !feat.closed?) then
          feat.status= $closed_status
          feat.done_ratio = 100
          feat.save()
          puts "     closing feature #{feat.id} #{feat.spec} #{feat.valid?}"
      end
     end
  end

