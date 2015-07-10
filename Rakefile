task :default => [:build]
task :test => [:build, :install]

task :build do
  system("gem build ./rtorrent_xmlrpc.gemspec")
end

task :install do
  gem = Dir['*.gem'].sort.last
  system("sudo gem install #{gem}")
end

task :push do
  gem = Dir['*.gem'].sort.last
  system("gem push #{gem}")
end

task :console do
  require 'hashie'
  require 'pry'
  require 'rtorrent_xmlrpc'

  def load_xmlrpc
    config = Hashie::Mash.load(File.expand_path('~/.config/rtorrent_xmlrpc.conf'))
    RTorrent::XMLRPC.new_from_hash(config)
  end

  def reload!
    # Change 'gem_name' here too:
    files = $LOADED_FEATURES.select { |feat| feat =~ /\/rtorrent_xmlrpc\// }
    files.each { |file| load file }
  end

  ARGV.clear
  Pry.start
end

task :run do
  ruby "-Ilib", 'bin/rtorrent_xmlrpc'
end
