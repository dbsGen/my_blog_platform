require 'template_path'

module Account::BlogHelper

  def public_settings
    if @public_settings.nil?
      @public_settings = Hashie::Mash.new current_user.blog_settings['public_settings']
    end
    @public_settings
  end

  # 设置的标签
  def setting_tag(setting, now_setting = {})
    case setting.type.downcase
      when 'string'
        text_field_tag "settings[#{setting.id}]", now_setting[setting.id] || setting.default, string_params(setting)
      else

    end
  end

  def preview_url
    "http://#{current_user.host_domain.word}.#{CONFIG.home_domain[0]}/preview"
  end

  private
  def string_params(setting)
    hash = {}
    length = setting['length']
    unless length.nil?
      if !length.minimum.nil? and !length.maximum.nil?
        hash[:check] = setting.type
        hash[:placeholder] = "长度必须在#{length.minimum.to_i}~#{length.maximum.to_i}之间。"
        hash[:minimum] = length.minimum
        hash[:maximum] = length.maximum
      elsif length.minimum.nil?
        hash[:check] = setting.type
        hash[:placeholder] = "必须少于或等于#{length.maximum.to_i}个字符。"
        hash[:maximum] = length.maximum
      elsif length.maximum.nil?
        hash[:check] = setting.type
        hash[:placeholder] = "必须大于或等于#{length.minimum.to_i}个字符。"
        hash[:minimum] = length.minimum
      end
    end
    hash
  end

  def options_myboka(collections, selected)
    html = ''
    collections.each do |c|
      html << "<option value='#{c.id}' #{c.id == selected ? 'selected="selected"' : '' }>#{c.screen_name}</option>"
    end
    raw html
  end
end
