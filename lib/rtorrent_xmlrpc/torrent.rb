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
    attr_accessor :base_filename, :base_path, :completed, :down_total, :files, :hash, :is_multi_file, :name, :size, :tied_to_file, :up_total
    attr_reader :labels, :priority, :ratio

    def completed?
      self.completed
    end

    def add_labels(labels)
      labels = [labels] if labels.is_a? String
      self.labels = (@labels + labels).uniq
    end

    def remove_labels(labels)
      labels = [labels] if labels.is_a? String
      self.labels = @labels - labels
    end

    def labels=(labels) # :nodoc:
      labels = labels.split(',') if labels.is_a? String
      @labels = labels
      # Remove extra whitespace from labels
      @labels.map!(&:strip)
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
      puts "         size: ".blue + Filesize.new(self.size).pretty.green
      puts "   downloaded: ".blue + Filesize.new(self.down_total).pretty.green
      puts "     uploaded: ".blue + Filesize.new(self.up_total).pretty.green
      puts "        ratio: ".blue + self.ratio.to_s.green
      puts "     priority: ".blue + self.priority_str.green
      puts "       labels: ".blue + self.labels_str.green
      puts "    completed: ".blue + self.completed.to_s.green
      if with_files
        puts "        files: ".blue + @files.first.green
        @files.each { |file| puts "               " + file.green unless file == @files.first }
      end
    end

    # FILTERS

    # Test if torrent has a specific label
    def has_label?(label)
      @labels.include? label.to_s
    end

  end

end
