module ThirdPartiesHelper
  def upload_input_tag(ext = nil, path = nil, type = nil)
    html = "<input  type=\"file\" name=\"file\" id=\"file\" onchange=\"fileSelected(this);\" style=\"display: none\""
    html += " data-tp-ext=#{ext}" if ext
    html += " data-tp-path=#{path}" if path
    html += " data-tp-type=#{type}" if type
    html += '/>'
    raw html
  end
end
