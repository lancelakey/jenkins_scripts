#!/usr/bin/env ruby

# Assign variables which are the same for every project
#
@project=ENV['JOB_NAME']
@build=ENV['BUILD_NUMBER']
@url=ENV['BUILD_URL']
@commit=ENV['GIT_COMMIT'] || "thereisnowaythisstringwillmatchanything"
@committer = %x(git log -1 --format=format:%an).chomp
@irc_channel=ENV['IRC_CHANNEL']


def post_to_irc(test_status)
  message_started = "Jenkins started #{@project} build #{@build} #{@commit_url}"
  message_broken = "#{@committer}: Something went wrong with #{@project} build #{@build} #{@test_results} #{@url}console"
  message_failed = "#{@committer}: #{@project} build #{@build} FAILED: #{@test_results} #{@url}console"
  message_passed = "#{@project} build #{@build} PASSED: #{@test_results} #{@url}console Cheers #{@committer}!"

  def curl_post(message)
    %x(curl -X POST ip_address/#{@irc_channel} -d '#{message}')
  end

  case test_status 
  when "test_started"
    curl_post(message_started)
  when "test_broken"
    curl_post(message_broken)
  when "test_failed"
    curl_post(message_failed)
  when "test_passed"
    curl_post(message_passed)
  end
end
