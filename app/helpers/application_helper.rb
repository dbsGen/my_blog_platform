module ApplicationHelper
  def navbar_li_tag(label, active = false)
    raw "<li class='divider-vertical#{active ? ' active' : ''}'>#{label}</li>"
  end

  def notifications
    flash[:information] || @information
  end

  def check_information
    def input_hash(str, hash)
      str << 'Messenger().post({'
      hash.each do |k, v|
        str << "#{k}: '#{v}',"
      end
      str << '});'
    end

    n = notifications
    return '' if n.nil? or n.size == 0
    notify = ''
    if n.is_a?(Array)
      n.each do |v|
        if v.is_a?(Hash)
          if v.size != 0
            input_hash(notify, v)
          end
        else
          notify << "Messenger().post('#{v}');"
        end
      end
    elsif n.is_a?(Hash)
      input_hash(notify, n)
    else
      notify << "Messenger().post('#{n}');"
    end
      raw <<-script
<script type="text/javascript">
//<![CDATA[
var ready = $(document).ready;
$(document).ready(function(){
  if (ready) ready();
  #{notify}
});
//]]>
</script>
      script

  end

  def pagination_tag(path, total, now, per_page = 25, total_to_show = 9)
    now = 1 if now.nil?
    now = now.to_i
    now = 1 if now < 1
    total = 1 if total.nil?
    total = total.to_i
    path = path[0..((path.index('?') || 0) - 1)]

    if total <= 1
      return ''
    end

    def path_on_page(path, page, per_page)
      "#{path}?page=#{page}&per_page=#{per_page}"
    end

    def li_in_pagination(active, show, path)
      if active == 'disabled' or active == ''
        "<li class='#{active}'><a>#{show}</a></li>"
      else
        "<li class='#{active}'><a href='#{path}'>#{show}</a></li>"
      end
    end

    #一共现实多少页
    tts = total > total_to_show ? total_to_show : total
    start = (now - tts / 2).ceil
    start = 1 if start < 1

    html = '<div class="pagination"><ul>'
    html << li_in_pagination(now <= 1 ? 'disabled' : 'active', '<<', path_on_page(path, 1, per_page))
    tts.times do |i|
      p = start + i
      html << li_in_pagination(now != p ? 'active' : '', p, path_on_page(path, p, per_page))
    end
    html << li_in_pagination(now >= total ? 'disabled' : 'active', '>>', path_on_page(path, total, per_page))
    html << '</ul></div>'
    raw html
  end

  def home?
    @page_index == :home
  end

  def popular?
    @page_index == :popular
  end

  def recommend?
    @page_index == :recommend
  end

  def last?
    @page_index == :last
  end

  def hidden_navbar?
    @hidden_navbar
  end

  def hidden_footer?
    @hidden_footer
  end

  def hidden_navbar
    @hidden_navbar = true
  end

  def hidden_footer
    @hidden_footer = true
  end

#  SEO
  def seo_meta
    html = ''
    unless @keys.nil?
      unless @keys.is_a? Array
        @keys = [@keys.to_s]
      end
      html << "<meta name='keywords' content='#{@keys * ','}'>"
    end
    unless @summary.nil?
      html << "<meta name='description' content='#{@summary}'>"
    end
    raw html
  end
end
