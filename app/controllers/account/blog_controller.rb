class Account::BlogController < ApplicationController
  before_filter :require_login

  def edit
    t_name = params[:t_name]
    t_version = params[:t_version]
    if t_name.nil?
      @template = current_user.blog_template
    else
      if t_version.nil?
        @template = Template.last_with_name t_name
      else
        @template = Template.find_by_name_and_version(t_name, t_version)
      end
      return render_404 unless current_user.usable_templates_and_check.include? @template
    end
    render layout: 'edit_blog'
  end

  def submit

  end

end
