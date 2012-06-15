#!/usr/bin/env ruby

# Assign variables which are the same for every project
#
@commit=ENV['GIT_COMMIT'] || "thereisnowaythisstringwillmatchanything"

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
