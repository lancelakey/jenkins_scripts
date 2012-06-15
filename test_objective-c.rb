#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'lib/', 'jenkins_helpers')

github_project_url = "https://github.com/user/repo"

JenkinsHelpers.github_url_shortener(github_project_url)

JenkinsHelpers.post_to_irc("build_started")

build_output = %x( 
ssh user@system "
cd /Users/user/repo;
killall 'iPhone Simulator';
set -o errexit;
set -o verbose;
xcodebuild -workspace project.xcworkspace -scheme 'Project Integration Tests' -sdk iphonesimulator clean build"
)
build_exit_status = $?.exitstatus
puts "Build output:"
puts build_output
puts "Build exit status: #{build_exit_status}"

test_output = %x( 
ssh user@system "
cd /Users/user/repo;
/Users/user/bin/waxsim -f 'iphone' '/Users/user/Library/Developer/Xcode/DerivedData/Project-bbfbuukkoktejrdbrahnsilcgruo/Build/Products/Debug-iphonesimulator/ProjectExample copy.app' > /tmp/KIF-$$.out 2>&1;
grep -q 'TESTING FINISHED: 0 failures' /tmp/KIF-$$.out;"
)
test_exit_status = $?.exitstatus
puts "Test output:"
puts test_output 
puts "Test exit status: #{test_exit_status}"

if (build_exit_status > 0)
  JenkinsHelpers.post_to_irc("build_failed")
  exit 1
elsif (build_exit_status == 0) && (test_exit_status > 1)
  JenkinsHelpers.post_to_irc("test_failed")
  exit 1
elsif (build_exit_status == 0) && (test_exit_status == 0)
  JenkinsHelpers.post_to_irc("test_passed")
  exit 0
else
  JenkinsHelpers.post_to_irc("test_broken")
  exit 1
end

