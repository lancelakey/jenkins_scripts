#!/usr/bin/env ruby

module JenkinsHelpers
  extend self

  def project
    ENV['JOB_NAME']
  end

  def build
    ENV['BUILD_NUMBER']
  end
  
  def url
    ENV['BUILD_URL']
  end

  def commit
    ENV['GIT_COMMIT'] || "thereisnowaythisstringwillmatchanything"
  end

  def committer
    %x(git log -1 --format=format:%an).chomp
  end

  def irc_channel
    ENV['IRC_CHANNEL']
  end

  def github_url_shortener(url)
    curl_form_result = %x(
    curl -s -i http://git.io -F "url=#{url}/commit/#{commit}" |
    awk '/Location/ {print $2}'
    ).chomp
    
    case curl_form_result
    when /http:\/\/git.io/
      @commit_url = curl_form_result
    else
      @commit_url = "#{url}/commit/#{commit}"
    end
  end
  

  def curl_post(message)
    %x(curl -X POST ip_address/#{irc_channel} -d '#{message}')
  end

  def post_to_irc(build_test_status)
    message_build_all_started = ['Jenkins has the runs', 'Jenkins Jenkins Jenkins...', 'Jenkins run all the everythings', 'Jenkins is going to make a mess'].shuffle.first
    message_build_started = "Jenkins started: #{project} build-#{build} #{@commit_url}"
    message_build_failed = "#{committer}: #{project} build-#{build} BUILD-FAILED #{url}console"
    message_test_failed = "#{committer}: #{project} build-#{build} TEST-FAILED #{url}console"
    message_test_passed = "Cheers #{committer}! #{project} build-#{build} TEST-PASSED #{url}console"
    message_website_deployed = "Cheers #{committer}! #{project} build-#{build} WEBSITE-DEPLOYED #{url}console"
    message_broken = "#{committer}: Something went wrong with #{project} build-#{build} #{url}console"
  
    case build_test_status
    when "build_all_started"
      curl_post(message_build_all_started)
    when "build_started"
      curl_post(message_build_started)
    when "build_failed"
      curl_post(message_build_failed)
    when "test_failed"
      curl_post(message_test_failed)
    when "test_passed"
      curl_post(message_test_passed)
    when "website_deployed"
      curl_post(message_website_deployed)
    when "test_broken"
      curl_post(message_broken)
    end
  end

  def post_to_irc_w_results(build_test_status, test_results)
    message_build_failed = "#{committer}: #{project} build-#{build} BUILD-FAILED #{url}console"
    message_test_failed = "#{committer}: #{project} build-#{build} TEST-FAILED: #{test_results} #{url}console"
    message_test_passed = "Cheers #{committer}! #{project} build-#{build} TEST-PASSED: #{test_results} #{url}console"
    message_broken = "#{committer}: Something went wrong with #{project} build-#{build} #{url}console"
  
    case build_test_status
    when "build_failed"
      curl_post(message_build_failed)
    when "test_failed"
      curl_post(message_test_failed)
    when "test_passed"
      curl_post(message_test_passed)
    when "test_broken"
      curl_post(message_broken)
    end
  end


end
