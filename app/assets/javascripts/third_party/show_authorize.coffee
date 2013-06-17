PluginName = 'oauth_show'
allSelecter = '.show-authorize'
defaultOptions = {
  baseUrl: '/third_parties/check_login/'
  done: ->
    location.reload()
  error: ->
    location.reload()
}

$[PluginName] = (element, options = {}) ->
  $that = $(element)
  type = $that.attr('data-type')
  url = $that.attr('data-url')
  ops = $.extend({}, defaultOptions, options)
  $that.click ->
    if url
      ops.url = url
    else
      ops.url = ops.baseUrl + type
    $.ajax(
      url: ops.url
      success: ->
        #已经登陆了
        if 'function' == typeof ops.done
          ops.done()
        else if 'string' == typeof ops.done
          eval(ops.done)
      error: (r) ->
        #没有登陆
        try
          data = JSON.parse(r.responseText)
          $.colorbox(
            iframe: true
            href: data.msg
            width: '80%'
            height: '80%'
          )
          window.auth_over = ->
            if 'function' == typeof ops.done
              ops.done()
            else if 'string' == typeof ops.done
              eval(ops.done)
        catch e
          if 'function' == typeof ops.error
            ops.error()
          else if 'string' == typeof ops.error
            eval(ops.error)
    )

$.fn[PluginName] = (options = {}) ->
  this.each ->
    $[PluginName](this, options)

$(document).ready ->
  $(allSelecter)[PluginName]()