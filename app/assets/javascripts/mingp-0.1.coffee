# 2013-5-3

#显示名片
HTML = "<div id=\'mingp-layer\' style=\'border: 2px solid black; display: none; position: absolute;z-index: 1000\' >\n    <div id=\'cover\' style=\'background-color: white; z-index: 2; position: absolute; width: 100%; height: 100%\'>\n        <img src=\"http://mingp.net/image/preloader-w8-cycle-black.gif\" style=\"left: 118px; top: 58px; position: absolute\">\n    </div>\n    <iframe name='mingp-iframe' scrolling=\'no\' style=\'border: none;width: 300px; height: 180px; z-index: 1;position: absolute; overflow: hidden\'></iframe>\n</div>\n<img id=\"mingpian-over-image\" src=\"\" style=\"display: none; position: absolute;z-index: 1001\">"
FORM_HTML = "<form id='mingp-from' method='post' target='mingp-iframe' style='display: none'><input type='text' name='display' id='display'/></form>"
url = 'http://www.mingp.net/public/mingpian?email='

pluginName = 'MingP'

allSelecter = '[mp-email]'
actionAttr = 'mp-action'
emailAttr = 'mp-email'
displayAttr = 'mp-display'
nicknameAttr = 'mp-nickname'

mouseX = 0
mouseY = 0

# next {fun: f, obj: o}
next = null
show_able = yes
Shwoing = null

$[pluginName] = (element, options = {}) ->
  return null unless element
  if typeof element == 'string'
    switch element
      when 'reset'
        t = $(Shwoing)
        email = t.attr(emailAttr)
        display = t.attr(displayAttr)
        nickname = t.attr(nicknameAttr)
        u = url + email
        u += "&nickname=#{nickname}" if nickname
        form = form_tag()
        form.attr('action', u)
        form.children('input').val(display)
        form.submit()
      else
        console.error("Method #{element} is not supported")
  else
    return $()[pluginName]({initAll: true}) if !element
    defaults = {}

    plugin = this
    plugin.settings = {}
    $element = $(element)

    plugin.init = ->
      plugin.settings = $.extend({}, defaults, options);

      initAllEllipsis()
    initAllEllipsis = ->
      action = $element.attr(actionAttr)
      action = 'mouseover' if !action

      $element.bind(action, ->
        show_carte(this)
      )
    plugin.init()

$.fn[pluginName] = (options) ->
  elements = if (options && options.initAll)then $(allSelecter) else this;
  elements.each ->
    that = $(this)
    params = {}
    plugin = null
    if (undefined == that.data(pluginName))
      plugin = new $[pluginName](this, params)
      that.data(pluginName, plugin)

$(document).mousemove (event) ->
  mouseX = event.pageX
  mouseY = event.pageY
  check_for_miss(event) if ($('#mingp-layer').length > 0 and $('#mingp-layer').css('display') != 'none')

show_carte = (that) ->
  if !show_able
    return next = {
      fun: show_carte
      obj: that
    }
  Shwoing = that
  t = $(that)
  email = t.attr(emailAttr)
  display = t.attr(displayAttr)
  nickname = t.attr(nicknameAttr)
  return null unless email
  layer = $('#mingp-layer')
  q_iframe = $('#mingp-layer iframe')
  if layer.length == 0
    $('body').append(HTML)
    layer = $('#mingp-layer')
    q_iframe = $('#mingp-layer iframe')
    q_iframe[0].onload = ->
      $('#mingp-layer #cover').fadeOut()
      $('#mingpian-over-image').fadeOut()
      $(this).css(left: 0, top: 0)

  reset(t)
  show(layer)
  offset = t.offset()
  layer[0].sourceRect = {
    width: t.width() + 'px'
    height: t.height() + 'px'
    left: offset.left + 'px'
    top: offset.top + 'px'
    opacity: 0
  }
  u = url + email
  u += "&nickname=#{nickname}" if nickname
  form = form_tag()
  form.attr('action', u)
  form.children('input').val(display)
  form.submit()

form_tag = ->
  form = $('#mingp-from')
  if form.length == 0
    form = $(FORM_HTML)
    form.appendTo('body')
  form

temp_object = null

@mouse_out = (that, event) ->
  check_for_miss(event)

check_for_miss = (event) ->
  offset = $('#mingp-layer').offset()
  border = {
    left : offset.left
    right : offset.left + $('#mingp-layer').width()
    top : offset.top
    bottom: offset.top + $('#mingp-layer').height()
  }
  if event.pageX > border.right ||
  event.pageX < border.left ||
  event.pageY > border.bottom ||
  event.pageY < border.top
    show_able = no
    miss($('#mingp-layer'))
  else
    show_able = yes


reset = (t) ->
  layer = $('#mingp-layer')
  offset = t.offset()
  if t[0].tagName == 'IMG'
    $('#mingpian-over-image').css(
      display: 'inline'
      opacity: 1
      width: t.width() + 'px'
      height: t.height() + 'px'
      left: offset.left + 'px'
      top: offset.top + 'px'
    )
    $('#mingpian-over-image').attr('src', t.attr('src'))
  else
    offset = {left: mouseX, top: mouseY}

  layer.css(
    width: t.width() + 'px'
    height: t.height() + 'px'
    left: offset.left + 'px'
    top: offset.top + 'px'
    display: 'inline'
    opacity: 1
  )
  $('#mingp-layer iframe').css(
    left: 0
    top: 0
  )
  $('#mingp-layer #cover').fadeIn(0)


show = (that) ->
  offset = that.offset()
  that.stop()
  img = $('#mingpian-over-image')
  img.animate(width: '64px',height: '64px') if img.css('display') != 'none'
  that.animate(
    width: '300px'
    height: '180px'
    left: (offset.left - 28) + 'px'
    top: (offset.top - 28) + 'px'
  )

miss = (that) ->
  that.stop()
  miss_count = 0
  ani_over = ->
    show_able = yes
    that.css(
      display: 'none'
    )
    $('#mingpian-over-image').fadeOut()
    if next
      next.fun(next.obj)
      next = null
  that.animate(that[0].sourceRect, 'normal', 'linear', ->

    miss_count += 1
    ani_over() if miss_count == 2
  )
  $('#mingp-layer iframe').stop()
  $('#mingp-layer iframe').animate({left: '-28px',top: '-28px'}, 'normal', 'linear', ->
    miss_count += 1
    ani_over() if miss_count == 2
  )
  $('#mingp-layer #cover').fadeIn()
$(->
  $()[pluginName]({initAll: true});
);
