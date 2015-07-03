Gem::Specification.new do |s|
  s.name        = 'rtorrent_xmlrpc'
  s.version     = '0.1'
  s.date        = '2015-07-02'
  s.summary     = 'A library and tool to query an rtorrent xmlrpc service.'
  s.authors     = ['Zan Loy']
  s.email       = 'zan.loy@gmail.com'
  s.homepage    = 'http://zanloy.com/ruby/rtorrent_xmlrpc/'
  s.license     = 'MIT'
  s.files       = `git ls-files`.split("\n") - %w[.gitignore]
  s.executables = ['rtorrent_xmlrpc']

  s.add_dependency 'colorize', '~> 0.7', '>= 0.7.7'
  s.add_dependency 'hashie', '~> 3.4', '>= 3.4.2'
  s.add_dependency 'thor', '~> 0.19', '>= 0.19.1'

end