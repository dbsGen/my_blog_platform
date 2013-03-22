require 'customer'

class Account::ThirdPartiesController < ApplicationController
  layout 'user_page'
  before_filter :require_login, :enter_page

  def show

  end

  def callback
    from = params[:from]
    code = request.query_parameters[:code]

    case from
      when 'baidu'
        token = BAIDU_CLIENT.auth_code.get_token(code, :redirect_uri => account_TP_callback_url(from))
        client = HTTPClient.new()
        user_info = client.post(BAIDU_SITE + BAIDU_USER_PATH, 'access_token' => token.token)
        params = JSON(user_info.body)
        name = params['uname']

        #失败
        return render_500 if name.nil?

        baidu = current_user.baidu_yun_info
        if baidu.nil?
          baidu = ThirdParty.create(
              :type => 'baidu_yun',
              :token => token.to_hash,
              :name => name,
              :other => user_info.body
          )
          current_user.third_parties << baidu
          baidu.save
        else
          baidu.set(
              :token => token.to_hash,
              :name => name,
              :other => user_info.body
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
          youku.set(
              :token => token.to_hash,
              :name => name,
              :other => user_info.body
          )
        end
    end
    render :layout => 'least'
  end

  def destroy
    @type = params[:type];
    case @type
      when 'baidu'
        tp = current_user.baidu_yun_info
    end
    return render_404 if tp.nil?
    tp.destroy

    respond_to do |format|
      format.html {render_404}
      format.js
    end
  end

  protected

  def enter_page
    @page_index = :third_parties
    @title = t('third_parties.title')
  end
end
