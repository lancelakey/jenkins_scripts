#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'lib/', 'jenkins_helpers')

github_project_url = "https://github.com/user/repo"

JenkinsHelpers.github_url_shortener(github_project_url)

JenkinsHelpers.post_to_irc("build_started")

build_output = %x( 
ls;
)
build_exit_status = $?.exitstatus
puts "Build output:"
puts build_output
puts "Build exit status: #{build_exit_status}"

test_output = %x( 
ls;
)
test_exit_status = $?.exitstatus
puts "Test output:"
puts test_output 
puts "Test exit status: #{test_exit_status}"

test_results = "smurf"

if (build_exit_status > 0)
  JenkinsHelpers.post_to_irc("build_failed")
  exit 1
elsif (build_exit_status == 0) && (test_exit_status > 0)
  JenkinsHelpers.post_to_irc_w_results("test_failed", test_results)
  exit 1
elsif (build_exit_status == 0) && (test_exit_status == 0)
  JenkinsHelpers.post_to_irc_w_results("test_passed", test_results)
  exit 0
else
  JenkinsHelpers.post_to_irc("test_broken")
  exit 1
end

