require 'colorize'
require 'filesize'
require 'hashie'
require 'xmlrpc/client'

module RTorrent

  class Torrent

    # Attributes
    attr_accessor :hash, :name, :completed, :base_filename, :base_path, :is_multi_file, :tied_to_file
    attr_reader :down_total, :labels, :priority, :ratio, :size, :up_total

    def down_total=(down_total) # :nodoc:
      @down_total = Filesize.new(down_total)
    end

    def labels=(labels) # :nodoc:
      @labels = labels.split(',')
      @labels.map! { |label| label.chomp }
    end

    def labels_str
      @labels.join(', ')
    end

    def priority=(priority) # :nodoc:
      begin
        @priority = priority.to_i
      rescue
        @priority = 2
      end
    end

    # Return priority converted to a human readable string
    def priority_str
      case @priority
      when 0
        "Off"
      when 1
        "Low"
      when 2
        "Normal"
      when 3
        "High"
      else
        "Unknown"
      end
    end

    def ratio=(ratio) # :nodoc:
      begin
        @ratio = ratio.to_f
      rescue
        @ratio = 0.0
      end
    end

    def size=(size) # :nodoc:
      @size = Filesize.new(size)
    end

    def up_total=(up_total) # :nodoc:
      @up_total = Filesize.new(up_total)
    end

    # Return hash of all values in Torrent
    def to_h
      {
        base_filename: @base_filename,
        base_path: @base_path,
        completed: @completed,
        hash: @hash,
        is_multi_file: @is_multi_file,
        labels: @labels,
        name: @name,
        priority: @priority,
        ratio: @ratio,
        size: @size,
        tied_to_file: @tied_to_file,
      }
    end

    # Single line header
    def self.header
      "hash : name : size : down : up : ratio : labels"
    end

    # All torrent data in a single string for output to screen
    def to_s
      "#{self.hash} : #{self.name} : #{self.size.pretty} : #{self.down_total.pretty} : #{self.up_total.pretty} : #{self.ratio} : #{self.labels_str}"
    end

    # All torrent data dumped to screen in color
    def pp
      puts "-------------- ".red
      puts "         hash: ".blue + self.hash.green
      puts "         name: ".blue + self.name.green
      puts "         size: ".blue + self.size.pretty.green
      puts "   downloaded: ".blue + self.down_total.pretty.green
      puts "     uploaded: ".blue + self.up_total.pretty.green
      puts "        ratio: ".blue + self.ratio.to_s.green
      puts "     priority: ".blue + self.priority_str.green
      puts "       labels: ".blue + self.labels_str.green
      puts "    completed: ".blue + self.completed.to_s.green
    end

    # FILTERS

    # Test if torrent has a specific label
    def has_label?(label)
      @labels.include? label.to_s
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
      #@server.call('d.multicall', 'main', 'd.hash=', 'd.name=', 'd.custom1=', 'd.complete=', 'd.base_filename=', 'd.base_path=', 'd.is_multi_file=', 'd.tied_to_file=', 'd.get_size').each do |stats|
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
      @torrents.each { |torrent| result << torrent if torrent.has_label? label }
      return result
    end
  end

end
