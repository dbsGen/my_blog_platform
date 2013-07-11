#  ajax queue 部分
#  document.ajax_loading 标志是否在loading
#= require tools/ajaxQueue
pluginName = 'tpPicture'


# 获得百度图片部分
# 需要优data-tp-id何data-path属性 或者放到options里面
# data-tp-id => id  三方品台id
# data-path => path 文件路径
# data-url => url   请求地址
# data-tp => type   类型
# params 其他属性在请求完成后会设置上去
$[pluginName] = (elements, options = {}) ->
  if typeof elements == 'string'
    switch elements
      when 'scan'
        scan_pictrue()
      else
  else
    elements.each ->
      $this = $(this)
      id = $this.attr('data-tp-id')
      path = $this.attr('data-path')
      type = $this.attr('data-tp')
      ops = $.extend({id: id, path: path, type: type}, options)
      tp_picture($this, ops)


$.fn[pluginName] = (options = {}) ->
  $[pluginName](this, options)

tp_picture = ($this, options) ->
  defaults = {
    url: '/third_parties/tp_url'
  }
  return false if $this.length < 1 or $this[0].tagName != 'IMG'
  ops = $.extend({}, defaults, options)
  $.ajax_q(
    type: 'get'
    url: "#{ops.url}/#{ops.type}"
    data: {
      tp_id: ops.id
      path: ops.path
    }
    success: (data) ->
      data = eval("(#{data})")
      url = "#{data.url}&tp_id=#{ops.id}"
      $this.attr('data-src', url)
      imageObj = new Image()
      imageObj.src = url
      imageObj.onload = ->
        $this.attr('src', url)
        $this.attr('scaned', 'true')
        params = ops.params
        if params
          for key in params
            $this.attr(key, params[key])
  )

scan_pictrue = ->
  $('[data-tp]').each ->
    $this = $(this)
    if $this.attr('scaned') != 'true'
      $this[pluginName]()

$(document).ready ->
  $('[data-tp]')[pluginName]();