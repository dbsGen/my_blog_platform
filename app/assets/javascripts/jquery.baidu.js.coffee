#  ajax queue 部分
#  document.ajax_loading 标志是否在loading
#= require tools/ajaxQueue



# 获得百度图片部分
# 需要优data-tp-id何data-path属性 或者放到options里面
$.fn.extend(
  tp_picture: (options) ->
    defaults = {
      url: '/third_parties/tp_url'
    }
    this.each ->
      return false if this.tagName != 'IMG'
      obj = $(this)
      option = $.extend(defaults, options)
      tp_id = obj.attr('data-tp-id')
      $.ajax_q(
        type: 'get'
        url: "#{option.url}/baidu"
        data: {
          tp_id: tp_id
          path: obj.attr('data-path')
        }
        success: (data) ->
          url = "#{data.url}&tp_id=#{tp_id}"
          obj.attr('data-src', url)
          imageObj = new Image()
          imageObj.src = url
          imageObj.onload = ->
            obj.attr('src', url)
            params = option.params
            if params
              for key in params
                obj.attr(key, params[key])
      )
)