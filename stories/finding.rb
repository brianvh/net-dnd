#!/usr/bin/env ruby
require 'helper'

this_dir = File.dirname(__FILE__)
with_steps_for :finding do
  run_file = File.join(this_dir, "stories", 'finding.story')
  run run_file
end