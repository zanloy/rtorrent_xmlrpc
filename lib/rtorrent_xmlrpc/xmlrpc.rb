require 'rtorrent_xmlrpc/torrent'
require 'rtorrent_xmlrpc/torrents'
require 'xmlrpc/client'

module RTorrent

  class XMLRPC
    attr_accessor :host, :user, :password, :path, :port
    attr_reader :connection_options, :use_ssl, :server, :torrents

    def initialize(host: 'localhost', port: nil, user: nil, password: nil, path: '/xmlrpc', use_ssl: false)
      unless port
        if use_ssl
          port = 443
        else
          port = 80
        end
      end
      self.host = host
      self.port = port
      self.user = user
      self.password = password
      self.path = path
      self.use_ssl = use_ssl
      @torrents = Torrents.new
      @status = :initialized
      connect
      fetch_torrents
    end

    def self.new_from_hash(hash = {})
      h = {}
      hash.each { |k,v| h[k.to_s.downcase.to_sym] = v }
      self.new(host: h[:host], port: h[:port], user: h[:user], password: h[:password], path: h[:path], use_ssl: h[:use_ssl])
    end

    def use_ssl=(use_ssl)
      fail "use_ssl must be a boolean value" unless use_ssl.is_a?(TrueClass) || use_ssl.is_a?(FalseClass)
      @use_ssl = use_ssl
    end

    # Connect to rtorrent xmlrpc service
    def connect
      return true if @status == :connected
      connection_options = {
        host: @host,
        port: @port,
        user: @user,
        password: @password,
        path: @path,
        use_ssl: @use_ssl,
      }
      @server = ::XMLRPC::Client.new3(connection_options)
      @status = :connected
    end

    # Disconnect from xmlrpc service
    def disconnect
      @server = nil
      @status = :disconnected
    end

    # Grab list of torrents from server
    def fetch_torrents
      self.connect unless @status == :connected
      @torrents = Torrents.new
      args = [
        'd.multicall',
        'main',
        'd.hash=',
        'd.name=',
        'd.custom1=',
        'd.complete=',
        'd.base_filename=',
        'd.base_path=',
        'd.is_multi_file=',
        'd.tied_to_file=',
        'd.get_size_bytes=',
        'd.get_down_total=',
        'd.get_up_total=',
        'd.get_ratio=',
        'd.get_priority=',
      ]
      @server.call(*args).each do |stats|
        torrent = RTorrent::Torrent.new
        torrent.hash = stats[0]
        torrent.name = stats[1]
        torrent.labels = stats[2]
        torrent.completed = stats[3] == 1 ? true : false
        torrent.base_filename = stats[4]
        torrent.base_path = stats[5]
        torrent.is_multi_file = stats[6] == 1 ? true: false
        torrent.tied_to_file = stats[7]
        torrent.size = stats[8]
        torrent.down_total = stats[9]
        torrent.up_total = stats[10]
        torrent.ratio = stats[11].to_f / 1000
        torrent.priority = stats[12]
        torrent.files = @server.call('f.multicall', torrent.hash, '', 'f.get_path=').flatten
        @torrents[torrent.hash] = torrent
      end
    end

    # Start a torrent
    def start(hash)
      @server.call('d.start', hash)
    end

    # Stop a torrent
    def stop(hash)
      @server.call('d.close', hash)
    end

    # Pause a torrent
    def pause(hash)
      @server.call('d.stop', hash)
    end

    # Add labels to torrent
    def add_labels(hash, labels)
      self.torrents[hash].add_labels(labels)
      @server.call('d.set_custom1', hash, self.torrents[hash].labels_str)
    end

    # Remove labels from torrent
    def remove_labels(hash, labels)
      self.torrents[hash].remove_labels(labels)
      @server.call('d.set_custom1', hash, self.torrents[hash].labels_str)
    end

    # Set the custom1 (label) field for a torrent
    def set_labels(hash, labels)
      labels = [labels] unless labels.is_a? Array
      @server.call('d.set_custom1', hash, labels.join(', '))
      self.torrents[hash].labels = labels
    end
  end

end
