Gem::Specification.new do |s|
  s.name        = 'rtorrent_xmlrpc'
  s.version     = '0.2.4'
  s.date        = '2015-07-10'
  s.summary     = 'A library and tool to query an rtorrent xmlrpc service.'
  s.description = 'This is a library to get torrent information from a remote rtorrent server.'
  s.authors     = ['Zan Loy']
  s.email       = 'zan.loy@gmail.com'
  s.homepage    = 'http://zanloy.com/ruby/rtorrent_xmlrpc/'
  s.license     = 'MIT'
  s.files       = `git ls-files`.split("\n") - %w[.gitignore]
  s.executables = ['rtorrent_xmlrpc']

  s.add_dependency 'colorize', '~> 0.7', '>= 0.7.7'
  s.add_dependency 'hashie', '~> 3.4', '>= 3.4.2'
  s.add_dependency 'filesize', '~> 0.1', '>= 0.1.0'
  s.add_dependency 'thor', '~> 0.19', '>= 0.19.1'

  s.add_development_dependency 'awesome_print', '~> 1.6', '>= 1.6.1'
  s.add_development_dependency 'pry', '~> 0.10', '>= 0.10.1'
  s.add_development_dependency 'rake', '~> 12.3', '>= 12.3.3'
end
