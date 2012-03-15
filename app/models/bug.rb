$bug_tracker       = Tracker.find_by_name("Bug")
$otd_tracker       = Tracker.find_by_name("OTD")
$criticity_id      = 34

class Bug  < Issue

  def Bug.all(product_id)
      r = []
      bugs =Issue.find(:all,:conditions => ["( tracker_id = ? OR tracker_id = ? ) AND project_id = ?",
                                            $otd_tracker.id,$bug_tracker.id,product_id],\
                         :include => [ :tracker , :fixed_version,:status ,:relations_from , :relations_to ]);
      bugs.each do |issue|
        bug = issue.becomes(Bug)
        r << bug
      end
      r
  end
  def criticity
      l = CustomValue.find(:all,:conditions => [ "customized_id=? AND custom_field_id=?" ,self.id, $criticity_id])
      if l.size == 0 then
         return "NOLEVEL"
      end
      l.first.value.to_s
   end
end