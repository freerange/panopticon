class SearchIndex
  def self.instance
    @@instance ||= Rummageable::Index.new(rummager_host, '/mainstream', logger: Rails.logger)
  end

  def self.rummager_host
    Plek.current.find('search')
  end
end
