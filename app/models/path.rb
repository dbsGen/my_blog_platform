class Path
  attr_accessor :path, :type

  def initialize(obj)
    if obj.is_a? Hash
      self.path = obj['path']
      self.type = obj['type'] || self.url[/[^.]+$/]
    elsif obj.is_a? String
      self.path = obj
      self.type = self.path[/[^.]+$/]
    end
  end

  def describe
    "#{path}"
  end
end