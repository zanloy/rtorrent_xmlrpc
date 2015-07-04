module RTorrent

  class Torrents < Hash
    def completed
      result = Torrents.new
      self.each do |hash, torrent|
        result[torrent.hash] = torrent if torrent.completed?
      end
      return result
    end
    def with_label(label)
      result = Torrents.new
      self.each do |hash, torrent|
        result[torrent.hash] = torrent if torrent.has_label? label
      end
      return result
    end
  end

end
