#!/usr/bin/env ruby

# Assign variables which change per project or in testing
#
@irc_channel=ENV['IRC_CHANNEL']
github_project_url = "https://github.com/user/repo"

# Assign variables which are the same for every project
#
@project=ENV['JOB_NAME']
@build=ENV['BUILD_NUMBER']
@url=ENV['BUILD_URL']
@commit=ENV['GIT_COMMIT'] || "thereisnowaythisstringwillmatchanything"
@committer = %x(git log -1 --format=format:%an).chomp


def github_url_shortener(url)
  curl_form_result = %x(
  curl -s -i http://git.io -F "url=#{url}/commit/#{@commit}" |
  awk '/Location/ {print $2}'
  ).chomp

  case curl_form_result
  when /http:\/\/git.io/
    @commit_url = curl_form_result
  else
    @commit_url = "#{url}/commit/#{@commit}"
  end
end

github_url_shortener(github_project_url)


def post_to_irc(test_status)
  message_started = "Jenkins started #{@project} build #{@build} #{@commit_url}"
  message_broken = "#{@committer}: Something went wrong with #{@project} build #{@build} #{@test_results} #{@url}console"
  message_failed = "#{@committer}: #{@project} build #{@build} FAILED: #{@test_results}. #{@url}console"
  message_passed = "#{@project} build #{@build} PASSED: #{@test_results}. #{@url}console Cheers #{@committer}!"

  def curl_post(message)
    %x(curl -X POST 174.127.47.95/#{@irc_channel} -d '#{message}')
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

post_to_irc("test_started")


(failure, success) = nil

test_output = `cake test; exit 0;`


test_output = %x(
ssh user@system "
killall java node
cd /srv/repo/
git stash
git pull
rm -rf /srv/repo/node_modules/
npm install
npm link --unsafe-perm
cake test
exit 0"
)

test_exit_status=$?.success?
puts "Test exit status: #{test_exit_status}"
puts
puts "Test output:"
puts test_output

test_output.split("\n").each do |line|
  if line =~ /(\d+)\s(errored)/
    failure = $2
    @test_results = "#{$1} errored"
  elsif line =~ /(\d+)\s(honored)/
    success = $2
    @test_results = "#{$1} honored"
  end
end

if (@test_results)
  if failure
    post_to_irc("test_failed")
    exit 1
  elsif success
    post_to_irc("test_passed")
    exit 0
  end
else
  post_to_irc("test_broken")
  exit 1
end
