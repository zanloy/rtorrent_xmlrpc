require 'colorize'
require 'filesize'
require 'json'
require 'xmlrpc/client'

module RTorrent

  class Torrent

    PRIORITIES = ['Off', 'Low', 'Normal', 'High']
    PRIORITY_OFF = 0
    PRIORITY_LOW = 1
    PRIORITY_NORMAL = 2
    PRIORITY_HIGH = 3

    def initialize
      @labels = []
      @files= []
    end

    # Attributes
    attr_accessor :base_filename, :base_path, :completed, :down_total, :files, :hash, :is_multi_file, :name, :size, :tied_to_file, :up_total
    attr_reader :labels, :priority, :ratio

    def completed?
      self.completed
    end

    def add_labels(labels)
      labels = Array(labels)
      labels.map!(&:strip)
      self.labels = @labels | labels
    end

    def remove_labels(labels)
      labels = Array(labels)
      labels.map!(&:strip)
      self.labels = @labels - labels
    end

    def labels=(labels) # :nodoc:
      labels = labels.split(',') if labels.is_a? String
      labels.map!(&:strip)
      @labels = labels
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
      PRIORITIES[@priority]
    end

    def ratio=(ratio) # :nodoc:
      @ratio = ratio.to_f
    end

    # Return hash of all values in Torrent
    def to_h
      {
        base_filename: @base_filename,
        base_path: @base_path,
        completed: @completed,
        files: @files,
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

    # Convert object to string as json
    def to_s
      self.to_h.to_json
    end

    # All torrent data dumped to screen in color
    def pp(with_files = false)
      i = 12
      puts ("-" * i).red
      puts "%s %s" % ['hash:'.rjust(i).blue, self.hash.green]
      puts "%s %s" % ['name:'.rjust(i).blue, self.name.green]
      puts "%s %s" % ['size:'.rjust(i).blue, Filesize.new(self.size).pretty.green]
      puts "%s %s" % ['downloaded:'.rjust(i).blue, Filesize.new(self.down_total).pretty.green]
      puts "%s %s" % ['uploaded:'.rjust(i).blue, Filesize.new(self.up_total).pretty.green]
      puts "%s %s" % ['ratio:'.rjust(i).blue, self.ratio.to_s.green]
      puts "%s %s" % ['priority:'.rjust(i).blue, self.priority_str.green]
      puts "%s %s" % ['labels:'.rjust(i).blue, self.labels_str.green]
      puts "%s %s" % ['completed:'.rjust(i).blue, self.completed.to_s.green]
      if with_files
        puts "%s %s" % ['files:'.rjust(i).blue, @files.first.green]
        @files.each { |file| puts "%s %s" % [' ' * i, file.green] unless file == @files.first }
      end
    end

    # FILTERS

    # Test if torrent has a specific label
    def has_label?(label)
      @labels.include? label.to_s
    end

    # Test if torrent has any of the labels
    def has_any_labels?(labels)
      ! (@labels & labels).empty?
    end

  end

end
