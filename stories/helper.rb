$LOAD_PATH.unshift "#{File.dirname(__FILE__)}/../lib"
require 'rubygems'
require 'spec/story'
require 'net/dnd'

def this_dir
  @dir ||= File.dirname(__FILE__)
end

Dir[File.expand_path("#{this_dir}/steps/*.rb")].uniq.each do |file|
  require file
end

# Run a story file from interior the stories directory
def run_story_file(story_name)
  run File.join("#{this_dir}/stories/#{story_name}.story")
end

def connect!(host, field_list)
  @dnd = Net::DND.start(host, field_list.split(/,/))
end

def find!(look_for, one=nil)
  @profile = @dnd.find(look_for, one)
end

def close!
  @dnd.close
end
