module RTorrent

  class Torrents < Array
    def completed
      result = Torrents.new
      self.each do |torrent|
        result << torrent if torrent.completed?
      end
      return result
    end
    def with_label(label)
      result = Torrents.new
      self.each do |torrent|
        result << torrent if torrent.has_label? label
      end
      return result
    end
  end

end
