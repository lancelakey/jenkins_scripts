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
git stash;
git pull;
haiku build;
)
build_exit_status = $?.exitstatus
puts "Build output:"
puts build_output
puts "Build exit status: #{build_exit_status}"

if (build_exit_status > 0)
  JenkinsHelpers.post_to_irc("build_failed")
  exit 1
elsif (build_exit_status == 0)
  JenkinsHelpers.post_to_irc("website_deployed")
  exit 0
else
  JenkinsHelpers.post_to_irc("test_broken")
  exit 1
end

