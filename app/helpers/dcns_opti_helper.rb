

module DcnsOptiHelper



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

  # reparation
  # pour toutes les features niveau 2 => passer


 
  # test les features niveau 3
  # test les features niveau 3 qui n'ont pas de feature parent
  def check1()
   
    count = 0
    features3 = Feature.all_by_level(3)
    features3.each do |f|
       if f.parent_feature == nil then
          puts "la feature niveau 3 #{f.id} n'a pas de feature parent #{f.subject}"
          count +=1
       end
    end
   
    puts " check1 => #{count}"
    return count==0
  end

  #test les users stories qui n'ont pas de features parentes
  def check2()
    userstories = UserStory.all


    count =0
    userstories.each do |us|
      if us.parent_feature == nil then
         puts "la user story #{us.id} n'est pas ratachée #{us.subject}"
         count +=1
      end
    end
    puts " check 2 => #{count}"
    return count == 0
  end


  # tests les features niveau 3 qui auraient plusieurs features n 2
  def check3()
    features3 = Feature.all_by_level(3)
    features3.each do |f|
       sf = f.sub_features
       if sf.count > 1 then
         puts " la feature niveau 3 #{i.id} na plus de 2 feature parentes"
         puts sf
       end
    end
  end

# Recherche d'anomalies
# rechercher les users stories qui sont liées à une feature n°3 mais aussi à sa Feature parente 

# rechercher les users stories qui ne sont pas attachés à une feature

# rechercher les features niveau 3 qui ne sont pas liés à des features niveau 2

# rechercher les liens qui se font à l'envers (from feature to user_story, from feature n2 to feature n3)

# rechercher des users stories qui sont effectés dans un sprint
# rechercher des users stories qui ne sont aps traiter dans le meme sprint que sa feature ( difficile )



  def dump_features()
     features3 = Feature.all_by_level(3)
     features3.each do |issue|
         puts "L=#{issue.level} #{issue.id}  #{issue.tracker_id} #{issue.story_points} #{issue.featuresize} #{issue.done_ratio} #{issue.subject}"
    end
  end

  def dump_userstories(f,space)
     f.userstories.each do |us|
        puts "#{space}   user story  ##{us.id} [SP= #{us.story_points}] #{shorten(us.subject,6)} "
     end
  end

  def print_feature(f)
     puts " Feature          ##{f.id}  #{f.level} [SP= #{f.featuresize} ]  #{f.subject}"
     f.sub_features.each do |sf|
        puts "   sub Feature #{sf.id} #{sf.level} #{shorten(sf.subject,6)}"
        dump_userstories(sf,"    ")
     end
     dump_userstories(f,"")

  end

  def dumpcvs()
     features = Feature.all_by_level(2)
     puts "redmine;spec;level;feature size;actual size;%done CAl;%done set;subject"
     features.each do |f|
        # redmine ; id ; niveau
        puts "#{f.id};\"#{f.spec}\";#{f.level};#{f.featuresize};#{f.actualsize};#{f.calculated_percent_done};#{f.done_ratio};\"#{shorten(f.subject,7)}\";\"#{f.fixed_version.name}\""
     end
  end 
end

