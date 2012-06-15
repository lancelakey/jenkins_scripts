#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'lib/', 'jenkins_helpers')

github_project_url = "https://github.com/user/repo"

JenkinsHelpers.github_url_shortener(github_project_url)

JenkinsHelpers.post_to_irc("build_started")

test_output = %x(bin/test http://test.example.com)
test_exit_status = $?.exitstatus
puts "Test output:"
puts test_output 
puts "Test exit status: #{test_exit_status}"

if (test_exit_status == 0)
  JenkinsHelpers.post_to_irc("test_passed")
  exit 0
else
  JenkinsHelpers.post_to_irc("test_failed")
  exit 1
end
