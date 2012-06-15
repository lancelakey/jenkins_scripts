#!/usr/bin/env ruby

require File.join(File.dirname(__FILE__), 'lib/', 'post_to_irc')
require File.join(File.dirname(__FILE__), 'lib/', 'github_url_shortener')

github_project_url = "https://github.com/user/repo"

github_url_shortener(github_project_url)

def started_manually
  ENV['STARTED_MANUALLY']
end

if (started_manually == "true")
  post_to_irc("test_started")
else
  puts "This test was not started manually"
end

test_output = %x( 
ssh root@system "
export DISPLAY=:99;
killall java node;
/etc/init.d/redis_6379 stop;
/etc/init.d/redis_6379 start;
cd /srv/repo/;
git stash;
git pull;
rm -rf /srv/repo/node_modules;
npm install --unsafe-perm;
/usr/local/jruby/lib/ruby/gems/1.8/bin/cucumber"
)

test_exit_status=$?.success?
puts "Test exit status: #{test_exit_status}"
puts
puts "Test output:"
puts test_output

test_output_array = test_output.split("\n")
@test_results = test_output_array[-3..-2]
puts
puts "Test results: #{@test_results}"
puts

test_results_failpasscount = @test_results.select { |item| item =~ /fail/ or item =~ /pass/ }.size
test_results_failcount = @test_results.select { |item| item =~ /fail/ }.size

if test_results_failpasscount == 0
  post_to_irc("test_broken")
  exit 1
elsif test_results_failcount == 0
  post_to_irc("test_passed")
  exit 0
elsif test_results_failcount > 0 
  post_to_irc("test_failed")
  exit 1
end
