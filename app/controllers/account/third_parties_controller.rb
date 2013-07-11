require 'customer'
require 'third_parties_api/baidu_api'

class Account::ThirdPartiesController < ApplicationController
  layout 'user_page'
  before_filter :require_confirm, :enter_page

  helper_method :baidu_path, :youku_path, :mingp_path, :path_with_type

  def show

  end

  def callback
    from = params[:type]
    code = request.query_parameters[:code]

    case from
      when 'baidu'
        token = BAIDU_CLIENT.auth_code.get_token(code, :redirect_uri => account_TP_callback_url(from))
        h_token = token.to_hash
        p h_token, Time.new
        params = BaiduApi.user_info(h_token)
        name = params['uname']

        #失败
        return render_500 if name.nil?

        baidu = current_user.baidu_yun_info
        if baidu.nil?
          baidu = ThirdParty.new(
              :type => 'baidu_yun',
              :token => h_token,
              :name => name,
              :other => params
          )
          current_user.third_parties << baidu
          baidu.save
        else
          baidu.update_attributes!(
              :token => h_token,
              :name => name,
              :other => params
          )
        end
      when 'youku'
        token = YOUKU_CLIENT.auth_code.get_token(code, :redirect_uri => account_TP_callback_url(from))
        client = HTTPClient.new()
        user_info = client.post(YOUKU_SITE + YOUKU_USER_PATH,
                                'access_token' => token.token,
                                'client_id' => YOUKU_CLIENT_ID
        )
        params = JSON(user_info.body)
        name = params['name']
        #失败
        return render_500 if name.nil?

        youku = current_user.youku_info
        if youku.nil?
          youku = ThirdParty.create(
              :type => 'baidu_yun',
              :token => token.to_hash,
              :name => name,
              :other => user_info.body
          )
          current_user.third_parties << youku
          youku.save
        else
          youku.update_attributes!(
              :token => token.to_hash,
              :name => name,
              :other => user_info.body
          )
        end
      when 'mingp'
        token = MINGP_CLIENT.auth_code.get_token(code, :redirect_uri => account_TP_callback_url(from))
        mingp = current_user.mingp_info
        if mingp.nil?
          mingp = ThirdParty.create(
              :type => 'mingp',
              :token => token.to_hash,
              :name => current_user.nickname
          )
          current_user.third_parties << mingp
          mingp.save
        else
          mingp.update_attributes!(
              :token => token.to_hash,
              :name => current_user.nickname
          )
        end
      else

    end
    render :layout => 'least'
  end

  def destroy
    @type = params[:type]
    case @type
      when 'baidu'
        tp = current_user.baidu_yun_info
        return render_404 if tp.nil?
        tp.destroy
      when 'youku'
        tp = current_user.youku_info
        return render_404 if tp.nil?
        tp.destroy
      when 'mingp'
        tp = current_user.mingp_info
        return render_404 if tp.nil?
        tp.destroy
      else

    end

    respond_to do |format|
      format.html {render_404}
      format.js
    end
  end

  def check_login
    type = params[:type]
    info = current_user.tp_info(type)
    if info.nil?
      render_format 404, path_with_type(type)
    else
      hash = {url: account_collections_path}
      hash[:title] = t('third_parties.baidu_yun') if type == 'baidu'
      render_format 200, hash
    end
  end

  def collections
    type = params[:type]
    folder = params[:folder] || '/'
    ext = params[:ext] || ''
    result = {}
    case type
      when 'baidu'
        token_info = current_user.baidu_yun_info
        return render_404 if token_info.nil?
        result = BaiduApi.files(token_info.token, folder, 0, 100)
        @tp_id = token_info.id
      else

    end
    exts = ext.split(',')
    if exts.size > 0
      l = result['list']
      @files = []
      l.each do |v|
        ex = v['path'][/[^\.]+$/]
        if exts.include? ex
          @files << v
        end
      end
    else
      @files = result['list'] || []
    end

    render :partial => 'account/third_parties/collections'
  end

  def upload_url
    type = params[:type]
    path = params[:path] || '/'
    ondup = params[:ondup] || 'overwrite'
    url = ''
    case type
      when 'baidu'
        token_info = current_user.baidu_yun_info
        return render_404 if token_info.nil?
        url = BaiduApi.upload(token_info.token, path, ondup)
      else

    end
    render_format 200, url
  end

  def baidu_path
    BAIDU_CLIENT.auth_code.authorize_url(:redirect_uri => account_TP_callback_url('baidu'), :scope => 'basic,netdisk')
  end

  def youku_path
    YOUKU_CLIENT.auth_code.authorize_url(:redirect_uri => account_TP_callback_url('youku'))
  end

  def mingp_path
    MINGP_CLIENT.auth_code.authorize_url(:redirect_uri => account_TP_callback_url('mingp'))
  end

  def path_with_type(type)
    case type
      when 'baidu'
        baidu_path
      when 'youku'
        youku_path
      when 'mingp'
        mingp_path
      else
    end
  end

  protected

  def enter_page
    @page_index = :third_parties
    @title = t('third_parties.title')
  end
end
