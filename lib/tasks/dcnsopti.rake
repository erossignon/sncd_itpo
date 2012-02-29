require 'fileutils'
require 'benchmark'

decimal_separator = ","
def f(value)
   value.to_s.gsub('.', decimal_separator)
end

def shorten (string, word_limit = 5)
  words = string.split(/\s/)
  if words.size >= word_limit
    last_word = words.last
    words[0,(word_limit-1)].join(" ") + '...' + last_word
  else
    string
  end
end

def assert
  raise "Assertion failed !" unless yield if $DEBUG
end

def update_feature(feat)

  feat.reload # for some reason, needed
  actual_done = feat.calculated_percent_done
  if actual_done != feat.done_ratio then
      puts " Updating feature #{feat.id} #{feat.spec} advancement from #{feat.done_ratio} to #{actual_done}"
      feat.done_ratio = actual_done
      if feat.done_ratio != 100 then
        feat.status= $encours_status
        # beware : An issue assigned to a closed version cannot be reopened
        feat.fixed_version.status = Version::VERSION_STATUSES[0]
        feat.fixed_version.save!
      end
      feat.save!
  end
  if ( feat.done_ratio == 100  and !feat.closed?) then
     feat.status= $closed_status
     feat.done_ratio = 100
     feat.save!
     puts "     closing feature #{feat.id} #{feat.spec} #{feat.valid?}"
  end

end

def update_features()
    # update feature level 3
    features3 = Feature.all_by_level(3)
    features3.each do |feat|
      update_feature(feat)
   end
   # now on feature level 2
   features2 = Feature.all_by_level(2)
   features2.each do |feat|
      update_feature(feat)
   end
end

# test les features niveau 3
def check1()
 puts "# check 1 : test les features niveau 3 qui n'ont pas de feature parents"
 count = 0
 features3 = Feature.all_by_level(3)
 features3.each do |f|
    if f.parent_feature == nil then
       puts "    la feature niveau 3 #{f.id} n'a pas de feature parent #{f.subject}"
       count +=1
    end
 end

 puts "# check1 : done ... => #{count} errors"
 return count==0
end

def check2()
puts "# check2: test les users stories qui n'ont pas de features parentes"
 userstories = UserStory.all
 count =0
 userstories.each do |us|
   if us.parent_feature == nil then
      puts "     la user story #{us.id} n'est pas rattachée #{us.subject}"
      count +=1
   end
 end
 puts "# check2 : done ... => #{count} errors"
 return count == 0
end



def check3()
 puts "check3 : tests les features niveau 3 qui auraient plusieurs features n 2"
 features3 = Feature.all_by_level(3)
 features3.each do |f|
    sf = f.sub_features
    if sf.count > 1 then
      puts "   la feature niveau 3 #{i.id} a plus de 2 features parentes"
      puts sf
    end
 end
 puts "check3 : done..."
end

# Recherche d'anomalies
# rechercher les users stories qui sont liées à une feature n°3 mais aussi à sa Feature parente

# rechercher les users stories qui ne sont pas attachés à une feature

# rechercher les features niveau 3 qui ne sont pas liés à des features niveau 2

# rechercher les liens qui se font à l'envers (from feature to user_story, from feature n2 to feature n3)

# rechercher des users stories qui sont effectés dans un sprint
# rechercher des users stories qui ne sont aps traiter dans le meme sprint que sa feature ( difficile )


def header_feature(f)
   "##{f.id.to_s.ljust(4)} #{f.level.to_s.ljust(2)}"
end
def info_feature(f)
  " [SP= #{f.featuresize.to_s.ljust(4)}]" \
  " [AP= #{f.actualsize.to_s.ljust(4)}]"   \
  " [done = #{f.done_ratio.to_s.ljust(3)}%]  #{shorten(f.subject)}"
end
def info_userstory(f)
  " [SP= #{f.story_points.to_s.ljust(4)}]" \
  " [AP= #{f.story_points.to_s.ljust(4)}]"   \
  " [done = #{f.done_ratio.to_s.ljust(3)}%]  #{shorten(f.subject)}"
end

def dump_userstories(f,space)
   f.userstories.each do |us|
     str1 = "#{space}   userstory  #{header_feature(us)}".ljust(40)
     puts "#{str1} #{info_userstory(us)}"
   end
end

def print_feature(f)
   str1 = "Feature  #{header_feature(f)}".rjust(40)
   puts "#{str1} #{info_feature(f)}"

   do_print_details = false
   if do_print_details then
     f.sub_features.each do |sf|
       str1 = "  sub feature  #{header_feature(sf)}".ljust(40)
       puts "#{str1} #{info_feature(sf)}"
       dump_userstories(sf,"    ")
     end
     dump_userstories(f,"")
     puts ""
   end
end

def extract_stat(features)

  sum_estimate          = 0
  sum_actual_size        = 0
  sum_estimate_done     = 0
  features.each do |f|
    sum_actual_size    += f.actualsize
    sum_estimate      += f.featuresize
    sum_estimate_done += f.featuresize * f.calculated_percent_done / 100.0
  end
  calculated_percent_done = 0
  calculated_percent_done  = (sum_estimate_done/sum_estimate*100 ).to_i unless sum_estimate==0

  [ sum_estimate , sum_actual_size ,sum_estimate_done ,calculated_percent_done ]
end
def print_feature_collection(features,title)

  currver = ""
  stats = extract_stat(features)
  sum_estimate            = stats[0]
  sum_actual_size          = stats[1]
  sum_estimate_done       = stats[2]
  calculated_percent_done = stats[3]

  puts "------------------------------------------------------"
  puts "        #{title}"
  puts "        charge selon estimation initiale   : #{sum_estimate}"
  puts "        charge totale en story points      : #{sum_actual_size}"
  puts "        percent done                       : #{calculated_percent_done}%"
  puts "------------------------------------------------------"
  features.each do |f|
    if currver != f.fixed_version.name then
      currver  = f.fixed_version.name
      puts " ##########  #{f.fixed_version.name} #{f.fixed_version.effective_date}"
    end
    print_feature f
  end

end
def printfeatures()
  update_features
  features = Feature.all_by_level(2).sort_by do  |f|
    [ f.fixed_version.effective_date , f.calculated_percent_done , f.spec ]
  end

  feature_done       = []
  feature_inprogress = []
  feature_todo       = []
  feature_outofscope = []


  features.each do |f|
    if f.done_ratio == 100 then
      feature_done << f
    elsif f.done_ratio != 0 then
      feature_inprogress << f
    elsif ( f.fixed_version.name =~ /V/ ) == nil then

      if f.userstories.count > 0 then
        feature_inprogress << f
      else
        feature_todo << f
      end
    else
      feature_outofscope << f
    end
  end


  stats = extract_stat(feature_inprogress)
  sum_estimate            = stats[0]
  sum_actualsize          = stats[1]
  sum_estimate_done       = stats[2]
  calculated_percent_done = stats[3]

  s = Stat.find_or_create_by_date 0.days.ago.beginning_of_day
  # find(:all, :condition => { 'date=?' => 0.days.ago} )
  s.done       = feature_done.sum { |f| f.featuresize }
  s.inprogress = feature_inprogress.sum { |f| f.featuresize }
  s.inprogress_done = sum_estimate_done
  s.todo       = feature_todo.sum { |f| f.featuresize }
  s.bonus      = feature_outofscope.sum { |f| f.featuresize }

  s.todo_feature_count            =  feature_todo.count
  s.inprogress_feature_count      =  feature_inprogress.count
  s.inprogress_done_feature_count =  feature_inprogress.count
  s.done_feature_count            =  feature_done.count
  s.bonus_feature_count           =  feature_outofscope.count
  s.save!

  print_feature_collection(feature_done, "Done")
  print_feature_collection(feature_inprogress, "In Progress")
  print_feature_collection(feature_todo, "A Faire")
end

def dumpcvs()

   # export = FCSV.generate(:col_sep => l(:general_csv_separator)) do |csv|
   # end

   features = Feature.all_by_level(2)
   features = features.sort_by {  |f|
     [   -f.calculated_percent_done ,  f.fixed_version.effective_date, f.spec ]
   }
   puts "redmine;spec;level;feature size;actual size;%done CAl;%done set;subject"
   features.each do |f|
      # redmine ; id ; niveau
      puts "#{f.id};\"#{f.spec}\";#{f.level};#{f.featuresize};"     \
           "#{f.actualsize};#{f.calculated_percent_done};#{f.done_ratio};\"#{shorten(f.subject,7)}\";\"#{f.fixed_version.name}\""
   end
end






def fix_tasks()
  task_tracker = Tracker.find_by_name("task").id
  tasks = Issue.find(:all, :conditions => [ 'tracker_id=?',task_tracker ])
  tasks.each do |task|
    if task.parent_id != nil
      us = task.parent.becomes(UserStory)
      # extraire le numéro d'exigence du titre
      us.subject =~ /[^a-z^A-Z ]*/
      exigence = $&
      puts exigence
      if not task.subject.include?(exigence)
        task.subject = "#{exigence} #{task.subject}"
        puts " setting task title to #{task.subject }"
        begin
          task.save!
        rescue
        end
      end
    end

  end

end


namespace :dcns do
  namespace :opti do
     desc "Met à jour l'avancement des features niveau 2"
     task :update_features => :environment do |t|
       raise "You must specify the RAILS_ENV ('rake dcns:opti:update_features RAILS_ENV=production' )"  unless ENV["RAILS_ENV"]
       #begin
       #  Rails.cache.clear
       #rescue NoMethodError
       #  puts "** WARNING: Automatic cache delete not supported by #{Rails.cache.class}, please clear manually **"
       #end
       puts "\n"
       puts "====================================================="
       puts "             Updating Feature advancement "
       puts "====================================================="
       update_features
     end
     desc "Effectue des tests d'intégrité"
     task :check => :environment do |t|
          check1
          check2
          check3
     end
     desc "Sort les statistiques d'avancement d'un un fichier CVS"
     task :dumpstat => :environment do |t|
       puts "====================================================="
       puts "             Dump Statistics"
       puts "====================================================="
       puts t
       dumpcvs
     end

    desc "dump des features"
    task :dumpfeatures => :environment do |t|
      puts t
      printfeatures()
    end

    desc "améliorer les titres des tâches de user story"
    task :fix_task_title => :environment  do |t|
      fix_tasks
    end


    desc "Dump Cumulative flow data"
    task :dumpCFD =>  :environment do |t|
      puts "date;todo;inprogress;inprogress_done;done;todo_feature_count;inprogress_feature_count;done_feature_count;bonus_feature_count"
      stats = Stat.all().sort_by { |s| s.date }
      stats.each do |s|
        puts "#{s.date};#{f(s.todo)};#{f(s.inprogress)};#{f(s.inprogress_done)};#{f(s.done)};"\
             "#{f(s.todo_feature_count)};#{f(s.inprogress_feature_count)};#{f(s.done_feature_count)};#{f(s.bonus_feature_count)}"
      end
    end
  end


end