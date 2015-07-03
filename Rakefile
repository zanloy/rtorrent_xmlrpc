task :default => [:build]
task :test => [:build, :install]

task :build do
  system("gem build ./rtorrent_xmlrpc.gemspec")
end

task :install do
  gem = Dir['*.gem'].last
  system("sudo gem install #{gem}")
end

task :push do
  gem = Dir['*.gem'].last
  system("gem push #{gem}")
end

task :console do
  exec "irb -I ./lib"
end

task :run do
  ruby "-Ilib", 'bin/rtorrent_xmlrpc'
end
