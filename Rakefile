# Look in the tasks/setup.rb file for the various options that can be
# configured in this Rakefile. The .rake files in the tasks directory
# are where the options are used.

load 'tasks/setup.rb'

ensure_in_path 'lib'
require 'net/dnd'
require 'net/dnd/version'

task :default => 'spec:specdoc'

PROJ.name = 'net-dnd'
PROJ.version = Net::DND::VERSION
PROJ.authors = 'Brian V. Hughes'
PROJ.email = 'brianvh@dartmouth.edu'
PROJ.url = 'http://dev.dartmouth.edu/projects/'
PROJ.rubyforge.name = 'net-dnd'

PROJ.spec.opts << '--color'

# EOF
