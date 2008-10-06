#!/usr/bin/env ruby
require File.dirname(__FILE__) + '/helper'

with_steps_for :single_find do
  run_story_file("single_find")
end
