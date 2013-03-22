module PeopleHelper
  def sidebar_li_tag(label, url, active = false)
    def sidebar_a_tag(label, url, active)
      "<a href='#{url}'><i class='icon-chevron-right'></i>#{label}</a>"
    end

    raw "<li#{active ? ' class="active"' : ''}>#{sidebar_a_tag(label, url, active)}</li>"
  end

  def sidebar_header_tag(label)
    raw "<li class='nav-header'>#{label}</li>"
  end
end
