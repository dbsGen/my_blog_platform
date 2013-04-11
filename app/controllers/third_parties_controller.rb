require 'third_parties_api/baidu_api'

class ThirdPartiesController < ApplicationController
  def tp_url
    tp_id = params[:tp_id]
    type = params[:type]
    type = 'baidu_yun' if type == 'baidu'
    path = params[:path]
    return render_404 if tp_id.nil?
    case type
      when 'baidu_yun'
        tp = ThirdParty.where(:id => tp_id).first
        return render_404 if tp.nil?
        #过期了需要刷新
        if tp.expire?
          new_token = BaiduApi.refresh_token(tp.token, BAIDU_CLIENT)
          tp.set(:token => new_token)
        end
        path = URI.decode path
        path.gsub!(BAIDU_ROOT_FOLDER, '')
        url = BaiduApi.download(tp.token, path)
        render_format 200, {url:url}
      else
        render_404
    end
  end
end
