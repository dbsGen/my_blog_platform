require 'third_parties_api/baidu_api'

module ThirdPartiesHelper
  def upload_input_tag(ext = nil, path = nil, type = nil)
    html = "<input  type=\"file\" name=\"file\" id=\"file\" onchange=\"fileSelected(this);\" style=\"display: none\""
    html += " data-tp-ext=#{ext}" if ext
    html += " data-tp-path=#{path}" if path
    html += " data-tp-type=#{type}" if type
    html += '/>'
    raw html
  end

  def replace_tp_tag(content)
    content.gsub(/<img[^>]+data-tp=[^>]+>/) do |match|
      str = match
      str = str + '</img>' unless match[/(\/>)|(<\/img>)/]
      h = Hash.from_xml(str)['img']

      tp_id = h['data_tp_id']
      type = h['data_tp']
      type = 'baidu_yun' if type == 'baidu'
      path = h['data_path']
      case type
        when 'baidu_yun'
          tp = ThirdParty.where(:id => tp_id).first
          return '' if tp.nil?
          if tp.expire?
            new_token = BaiduApi.refresh_token(tp.token, BAIDU_CLIENT)
            tp.update_attributes!(:token => new_token)
          end
          path = URI.decode path
          path.gsub!(BAIDU_ROOT_FOLDER, '')
          url = BaiduApi.download(tp.token, path)
          h.delete 'data_tp_id'
          h.delete 'data_tp'
          h.delete 'data_path'

          x = '<img '
          h.each do |k, v|
            x << "#{k}='#{j v}' "
          end
          x << "src='#{url}'>"
          x
        else
          ''
      end
    end
  end
end
