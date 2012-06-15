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

(number_of_tests, failures, outputline) = nil

build_output = %x(
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
rake update;
)
build_exit_status = $?.exitstatus
puts "Build output:"
puts build_output
puts "Build exit status: #{build_exit_status}"

test_output = %x(
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin;
rake test;
)
test_exit_status = $?.exitstatus
puts "Test output:"
puts test_output 
puts "Test exit status: #{test_exit_status}"

test_output.split("\n").each do |line|
  if line =~ /(\d+)\sexample.+?(\d+)\sfail/
    number_of_tests = $1.to_i
    failures = $2.to_i
    test_results = line
  end
end

if (build_exit_status > 0)
  JenkinsHelpers.post_to_irc("build_failed")
  exit 1
elsif (build_exit_status == 0) && (test_exit_status > 0)
  JenkinsHelpers.post_to_irc("test_failed")
  exit 1
elsif (build_exit_status == 0) && (test_exit_status == 0)
  JenkinsHelpers.post_to_irc("test_passed")
  exit 0
else
  JenkinsHelpers.post_to_irc("test_broken")
  exit 1
end

