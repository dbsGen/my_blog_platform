class Account::Admin::UsersController < ApplicationController
  layout 'layouts/user_page'
  before_filter :require_admin, :enter_users
  before_filter :find_user, :except => [:index, :search]

  def index
    @title = "#{t('admin.title')}>#{t('admin.users')}"
    per_page = params[:per_page] || 25;
    @total_page = User.all().count / per_page + 1
    @users = User.paginate(
        :order    => :register_time.asc,
        :per_page => per_page,
        :page     => params[:page],
    )
    respond_to do |format|
      format.html
      format.js {render :template => 'account/admin/users/search'}
    end
  end

  def search
    @title = "#{t('admin.title')}>#{t('admin.users')}"
    per_page = params[:per_page] || 25;
    users = User.where :name => /#{params[:key]}/
    @users = users.paginate(
      :order    => :register_time.asc,
      :per_page => per_page,
      :page     => params[:page],
    )
    @total_page = users.count / per_page + 1
    respond_to do |format|
      format.html {render_404}
      format.js
    end
  end

  def show
    @title = "#{t('admin.title')}>#{t('admin.users')}>#{@user.name}"
    @sessions = @user.sessions
  end

  def update
    p "get params : #{params}"
    hash = {
        :email => params[:email],
        :summary => params[:summary]
    }

    password = params[:password]
    if !password.nil? and password.length > 0
      hash[:password_plain] = password
    end
    @ret = @user.set(hash)
    respond_to do |format|
      format.html {render_404}
      format.js
    end
  end

  def destroy
    @user_id = dom_id @user
    @user.destroy

    respond_to do |format|
      format.html {render_404}
      format.js
    end
  end

  protected

  def find_user
    @user = User.first :id => params[:id]
    if @user.nil?
      return render :file => "public/404.html", :status => 404
    end
    @user
  end

  def enter_users
    @page_index = :admin_users
  end

end
