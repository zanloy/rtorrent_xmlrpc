module RTorrent

  class Torrents < Hash

    def completed
      result = Torrents.new
      self.each do |hash, torrent|
        result[torrent.hash] = torrent if torrent.completed?
      end
      return result
    end

    def with_labels(labels)
      labels = [labels] unless labels.is_a? Array
      result = Torrents.new
      self.each do |hash, torrent|
        result[torrent.hash] = torrent if torrent.has_labels? labels
      end
      return result
    end

    def with_any_labels(labels)
      labels = [labels] unless labels.is_a? Array
      result = Torrents.new
      self.each do |hash, torrent|
        result[torrent.hash] = torrent if torrent.has_any_labels? labels
      end
      return result
    end

  end

end
