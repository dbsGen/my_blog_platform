class SaveError < RuntimeError
  def self.new(*objects)
    super(message_in_objects(*objects))
  end

  def self.message_in_objects(*objects)
    message = ''
    objects.each do |object|
      object.errors.messages.each do |_,v|
        message << "#{v.split(';')}\r\n"
      end
    end
    message
  end
end