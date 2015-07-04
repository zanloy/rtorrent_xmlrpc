# rtorrent_xmlrpc

**I seriously recommend you do NOT use this library until it has a v1.0
release. I am constantly changing things in it that will break functionality.**

This is a simple ruby library designed to pull basic information about torrents
from a remote rtorrent server using xmlrpc. It is not designed have complete
coverage of all features and methods provided by the xmlrpc interface. It is
only designed to have enough to manage your torrents from scripts. Included in
this gem is a binary that provides some basic functionality from the command
line in case you need to use it from non-ruby scripts.
