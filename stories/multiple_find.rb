#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/helper'

with_steps_for :multiple_find do
  run_story_file("multiple_find")
end
