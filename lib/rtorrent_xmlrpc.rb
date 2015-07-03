require 'colorize'
require 'hashie'
require 'xmlrpc/client'

module RTorrent

  class Torrent
    attr_accessor :hash, :name, :completed, :base_filename, :base_path, :is_multi_file, :tied_to_file
    attr_reader :labels

    def has_label(label)
      @labels.include? label.to_s
    end

    def labels=(labels)
      @labels = labels.split(',')
    end

    def to_h
      {
        hash: @hash,
        name: @name,
        labels: @labels,
        completed: @completed,
        base_filename: @base_filename,
        base_path: @base_path,
        is_multi_file: @is_multi_file,
        tied_to_file: @tied_to_file,
      }
    end

    def pp
      puts "-------------- ".red
      puts "         hash: ".blue + @hash.green
      puts "         name: ".blue + @name.green
      puts "       labels: ".blue + @labels.join(', ').green
      puts "    completed: ".blue + @completed.to_s.green
      puts "base_filename: ".blue + @base_filename.green
      puts "    base_path: ".blue + @base_path.green
      puts "is_multi_file: ".blue + @is_multi_file.to_s.green
      puts " tied_to_file: ".blue + @tied_to_file.green
    end
  end

  class XMLRPC
    attr_accessor :host, :user, :password, :path
    attr_reader :port, :use_ssl, :torrents

    def initialize(host:, port: 80, user:, password:, path: '/xmlrpc', use_ssl: false)
      self.host = host
      self.port = port
      self.user = user
      self.password = password
      self.path = path
      self.use_ssl = use_ssl
      @torrents = []
      @status = :initialized
    end

    def port=(port)
      fail unless port.is_a? Integer
      @port = port
    end

    def use_ssl=(use_ssl)
      fail unless use_ssl.is_a?(TrueClass) || use_ssl.is_a?(FalseClass)
      @use_ssl = use_ssl
    end

    # Connect to rtorrent xmlrpc service
    def connect
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

    # Grab list of torrents from server
    def fetch_torrents
      self.connect unless @status == :connected
      @torrents = []
      @server.call('d.multicall', 'main', 'd.hash=', 'd.name=', 'd.custom1=', 'd.complete=', 'd.base_filename=', 'd.base_path=', 'd.is_multi_file=', 'd.tied_to_file=').each do |stats|
        torrent = RTorrent::Torrent.new
        torrent.hash = stats[0]
        torrent.name = stats[1]
        torrent.labels = stats[2]
        torrent.completed = stats[3] == 1 ? true : false
        torrent.base_filename = stats[4]
        torrent.base_path = stats[5]
        torrent.is_multi_file = stats[6] == 1 ? true: false
        torrent.tied_to_file = stats[7]
        @torrents << torrent
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

    # Get a list of completed torrents
    def completed
      result = []
      @torrents.each { |torrent| result << torrent if torrent.completed }
      return result
    end

    # Get a list of incomplete torrents
    def incomplete
      result = []
      @torrents.each { |torrent| result << torrent unless torrent.completed }
      return result
    end

    # Get a list of torrents with label
    def with_label(label)
      result = []
      @torrents.each { |torrent| result << torrent if torrent.has_label(label) }
      return result
    end
  end

end
