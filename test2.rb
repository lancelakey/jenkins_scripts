#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'lib/', 'jenkins_helpers')

github_project_url = "https://github.com/user/repo"

JenkinsHelpers.github_url_shortener(github_project_url)

JenkinsHelpers.post_to_irc("build_started")

build_output = %x(
ssh user@system "
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/spirometer/bin:/var/lib/gems/1.8/bin;
cd /usr/local/repo/;
git stash;
git pull;
rake update;"
)
build_exit_status = $?.exitstatus
puts "Build output:"
puts build_output
puts "Build exit status: #{build_exit_status}"

test_output = %x(
ssh user@system "
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/local/spirometer/bin:/var/lib/gems/1.8/bin;
foo;"
)
test_exit_status = $?.exitstatus
puts "Test output:"
puts test_output 
puts "Test exit status: #{test_exit_status}"

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

