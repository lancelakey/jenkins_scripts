#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'lib/', 'jenkins_helpers')

github_project_url = "https://github.com/user/repo"

JenkinsHelpers.github_url_shortener(github_project_url)

def started_manually
  ENV['STARTED_MANUALLY']
end

if (started_manually == "true")
  JenkinsHelpers.post_to_irc("build_started")
else
  puts "This test was not started manually"
end

build_output = %x( 
rm -rf node_modules
sudo npm install
sudo npm link
)
build_exit_status = $?.exitstatus
puts "Build output:"
puts build_output
puts "Build exit status: #{build_exit_status}"

test_output = %x( 
cake test:node
)
test_exit_status = $?.exitstatus
puts "Test output:"
puts test_output 
puts "Test exit status: #{test_exit_status}"

test_output_array = test_output.split("\n")
test_results = test_output_array[-2]
puts "Test results: #{test_results}"

if test_results =~ /\[32m(\d+)\s+\w+,\s+(\d+)\s+\w+,\s+(\d+)/
  test_results_test_count = $1.to_i
  test_results_assertion_count = $2.to_i
  test_results_fail_count = $3.to_i
  test_results_exit_status = 0
else
  test_results_exit_status = 1
end

if (build_exit_status > 0)
  JenkinsHelpers.post_to_irc("build_failed")
  exit 1
elsif (build_exit_status == 0) && (test_results_fail_count > 0)
  JenkinsHelpers.post_to_irc_w_results("test_failed", test_results)
  exit 1
elsif (build_exit_status == 0) && (test_results_fail_count == 0)
  JenkinsHelpers.post_to_irc_w_results("test_passed", test_results)
  exit 0
else
  JenkinsHelpers.post_to_irc("test_broken")
  exit 1
end

