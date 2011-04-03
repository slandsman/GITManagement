# seed.rb

# Script to seed, initialize, push a repository to a webdav server, and
# clone it.

# Inspired by the excellent instructions provided at http://priodev.blogspot.com/2010/02/hosting-your-git-repository-on.html

# 1. From command line, get the following
#  a. name of the repository
#  b. location of the local repository
#  c. URL of the git repo
#  d. Username of the webdav user
# 2. Create the bare git repository in a temporary directory
# 3. Ask the user to upload the repository as specified in (1c-d)
# 4. Pull the repository to location specified in (1a-b)
# 5. Create a seed file (touch README), add, and commit it
# 6. Push changes to the remote repo

# test run looks like:
# ruby seed.rb -projectsloc /Users/seth/Desktop/testRepo -reponame MyTestRepo -user seth -url http://foo.bar.com/repos

# Copyright 2011 Seth Landsman <seth@homeforderangedscientists.net>
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

# ChangeLog:
#  v1.0 - initial draft - Seth Landsman <seth@homeforderangedscientists.net>

require 'optiflag'
require 'tmpdir'

module DBChecker extend OptiFlagSet
   flag "projectsloc"
   flag "reponame"
   flag "user"
   flag "url"
   
   and_process!
end 

def calculate_local_location(projects_loc, repo_name)
	if (!projects_loc.end_with?("/"))
		projects_loc += "/"
	end
	_ll = projects_loc + repo_name;
	return _ll
end

def calculate_remote_location(repo_name, url, user)
	_rl = url.sub("://", "://#{user}@")

	if (!_rl.end_with?("/")) 
		_rl += "/"
	end

	_rl += repo_name + ".git"

	return _rl
end

def calculate_temporary_location(repo_name)
	_tl = Dir.tmpdir + "/" + repo_name

	return _tl
end

puts "Attempting to create a new git repository."
puts "Step 1 - validating parameters - "

local_location = calculate_local_location(ARGV.flags.projectsloc, ARGV.flags.reponame)
remote_location = calculate_remote_location(ARGV.flags.reponame, ARGV.flags.url, ARGV.flags.user)

puts " The local location is #{local_location}"
puts " and the remote location is #{remote_location}"

temp_location = calculate_temporary_location(ARGV.flags.reponame) + ".git"

puts "Step 2 - creating a bare repo is a temporary directory - "
puts " The temporary location is #{temp_location}"

if (Dir.exists?(temp_location))
	FileUtils.rm_rf(temp_location)
end
Dir.mkdir(temp_location)
Dir.chdir(temp_location)

`git --bare init`
`touch git-daemon-export-ok`
`git --bare update-server-info`
`mv hooks/post-update.sample hooks/post-update`

puts "Step 3 - upload the repository to the remote location - "
puts " the remote location is #{remote_location}"
puts " Please copy #{temp_location} to #{remote_location} and hit enter"
STDOUT.flush
STDIN.gets

puts "Step 4 - pulling repository from the remote location - "
puts " Pulling #{remote_location} to #{ARGV.flags.projectsloc}"

if (Dir.exists?(local_location))
  puts "Cannot overwrite existing directory"
  exit 1
end

if (!Dir.exists?(ARGV.flags.projectsloc))
  Dir.mkdir(ARGV.flags.projectsloc)
end

Dir.chdir(ARGV.flags.projectsloc)
`git clone #{remote_location}`

puts "Step 5 - creating, committing, and pushing a seed file - "
puts " Touching README"
Dir.chdir(ARGV.flags.reponame)
`touch README`
puts " Checkin and commit README"
`git add README`
`git commit -m \"Seeding repository\"`
`git push origin master`











