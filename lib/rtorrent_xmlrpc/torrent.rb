require 'colorize'
require 'filesize'
require 'json'
require 'xmlrpc/client'

module RTorrent

  class Torrent

    def initialize
      @labels = []
      @files= []
    end

    # Attributes
    attr_accessor :base_filename, :base_path, :completed, :files, :hash, :is_multi_file, :name, :tied_to_file
    attr_reader :down_total, :labels, :priority, :ratio, :size, :up_total

    def completed?
      self.completed
    end

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
      if with_files
        puts "        files: ".blue
        @files.each { |file| puts "               " + file.green }
      end
    end

    # FILTERS

    # Test if torrent has a specific label
    def has_label?(label)
      @labels.include? label.to_s
    end

  end

end
