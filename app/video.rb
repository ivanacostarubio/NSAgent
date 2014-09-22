class Video
  PROPERTIES = [:url,:date]
  CHAR_SPLIT = "|"

  PROPERTIES.each do |prop|
    attr_accessor prop
  end

  def initialize(attrs = {})
    puts "#{self.attributes}"
    attrs.each do |key, value|
      self.send("#{key.to_s}=", value) if PROPERTIES.member? key.to_sym
    end
    puts "#{self.attributes}"

  end


  def self.all
    all_videos_hash.map{|_, value| puts(value); new(value)}
  end

  def self.destroy_all
    store = storage
    store['videos'] = {}
  end

  def save
    save_in_storage(attributes)
  end

  def attributes
    PROPERTIES.inject({}) do |hash,prop|
      hash[prop] = self.send(prop)
      hash
    end
  end

  private

  def save_in_storage(attrs)
    store = NSUserDefaults.standardUserDefaults
    store['videos'] ||= {}
    clone = store['videos'].mutableCopy
    $attrs = attrs
    clone["#{date.to_i}"] = attrs
    store['videos']= clone
  end

  def self.all_videos_hash
    storage['videos'] = {} if storage['videos'].nil?
    storage['videos']
  end

  def self.storage
    NSUserDefaults.standardUserDefaults
  end

  def storage
    Video.storage
  end
end