#需要使用的话需要在按钮上加上data-tp属性（baidu or youku），也可一加上data-tp-ext(文件类型). data-tp-path(文件夹目录)
#= require jquery.colorbox-min
#= require jquery-ui
#= require jquery.fileupload

body_html = (title, type, ext, path, for_tag) ->
  for_tag = for_tag.replace(/"/g, '\'')
  html = "<div id=\'tp-modal\' class=\"modal hide fade\" data-for-tag=\"#{for_tag}\"><div class=\"modal-header\">"
  html += "<button type=\"button\" class=\"close\" data-dismiss=\"modal\" aria-hidden=\"true\">&times;</button>"
  html += "<h3>#{title}</h3>\n</div>\n<div class=\"modal-body\">\n<div class=\'tabbable\'>"
  html += "<ul class=\"nav-tabs nav\">\n<li class=\"active\">\n<a href=\"#tab1\" data-toggle=\'tab\'>储存空间</a>"
  html += "</li><li><a href=\"#tab2\" data-toggle=\'tab\'>上传</a>\n</li>\n</ul>\n<div class=\"tab-content\">"
  html += "<div class=\"tab-pane active\" id=\"tab1\" style=\'max-height: 200px;overflow:auto;padding: 2px\'></div>"
  html += "<div class=\"tab-pane\" id=\"tab2\">"
  html += "<input  type=\"file\" name=\"file\" id=\"file\" onchange=\"fileSelected(this);\" style=\"display: none\""
  html += " data-tp-ext=#{ext}" if ext
  html += " data-tp-path=#{path}" if path
  html += " data-tp-type=#{type}" if type
  html += "/>"
  html += "<label>\n<input id=\"file-shower\" type=\"text\" disabled onclick=\"$('#tp-modal #file').click()\" style=\"position: relative;top: 4px\"/>\n"
  html += "<a class=\"btn\" onclick=\"$('#tp-modal #file').click()\">浏览...</a>\n"
  html += "<a id=\"upload-button\" class=\"btn disabled\" onclick='upload_click(this);'>上传</a></label>"
  html += "<div id='progress' class=\"progress progress-striped active\"><div id='progress-bar' class=\"bar\" style=\"width: 0;\"></div></div>"
  html += "</div></div></div></div>"
  html += "<div class=\"modal-footer\"><a onclick=\"$(\'#tp-modal\').modal(\'hide\')\" class=\"btn\">关闭</a><a onclick=\'select_click()\' class=\"btn btn-primary\">OK</a></div></div>"
  html

@open_tp_modal = (tag) ->
  btn = $(tag)
  ext = btn.attr('data-tp-ext')
  path = btn.attr('data-tp-path')
  for_tag = btn.attr('for')
  show_tp(btn.attr('data-tp'), ext, path, for_tag)
  no

show_tp = (type, ext, path, for_tag) ->
  url = "/account/third_parties/check_login/" + type
  $.ajax(
#     TODO 这里的地址是写死的，请注意
    url: url
    success: (data) ->
#        已经有三方登陆
      modal = $('#tp-modal')
      if modal.length == 0
        $('body').append(body_html(data.title, type, ext, path, for_tag))
        $('#tp-modal a[href="#tab1"]').on('show', ->
          f_open_modal(data.url, ext, path)
        )
        modal = $('#tp-modal')
      else
        $('#tp-modal ul li:first a').tab('show')
      modal.modal('show')
      f_open_modal(data.url, ext, path)
    error: (r)->
#        没有三方登陆
      data = eval("(#{r.responseText})")
      $.colorbox({
                 iframe: true
                 href: data.msg
                 width: '80%'
                 height: '80%'
                 })
  )

f_open_modal = (url, ext, path) ->
  if ext or path
    url += '?'
    url += "ext=#{ext}&" if ext
    url += "folder=#{path}" if path
  $.ajax(
    url: url
    success: (data) ->
      $('#tab1').html(data)
  )
  f_no()

f_ok = ->
  $('#file-shower').val($('#tp-modal #file').val())
  $('#upload-button').removeClass('disabled')
  $('#tp-modal #progress .bar').css('width', '0')
  $('#tp-modal #progress').addClass('progress-striped active')
  progress = $('#tp-modal #progress')
  progress.removeClass('progress-success')
  progress.removeClass('progress-danger')
f_no = ->
  $('#file-shower').val('')
  $('#upload-button').addClass('disabled')
  $('#tp-modal #progress .bar').css('width', '0')
  $('#tp-modal #progress').addClass('progress-striped active')
  progress = $('#tp-modal #progress')
  progress.removeClass('progress-success')
  progress.removeClass('progress-danger')
f_ext_not_match = (ext) ->
  f_no()
  Messenger().post(
    type: 'error'
    message: "只接受#{ext}后缀的文件"
  )

@auth_over = (value, type) ->
  $.fn.colorbox.close();
  show_tp(type)

@close_click = ->
  $('#tp-modal').modal('hide')
  no

@select_click = ->
  src = $('ul.files-list li.file_box.active a.thumbnail img[data-src]').attr('data-src')
  modal = $('#tp-modal')
  tag = modal.attr('data-for-tag')
  $(tag).val(src)
  console.log(src)
  modal.modal('hide')
  no

@select_file = (tag) ->
  $('ul.files-list li.file_box.active').removeClass('active')
  $(tag).parents('li.file_box').addClass('active')
  no

@fileSelected = (tag) ->
  t = $(tag)
  ext = t.attr('data-tp-ext')
  if ext
    exts = ext.split(',')
    filename = t.val()
    e = filename.match(/[^\.]+$/)
    w = filename.match(/\./)
    return f_ext_not_match(ext) unless w or e
    b = false
    for v in exts
      e_str = e[0]
      if e_str == v
        b = true
        break
    if b
      f_ok()
    else
      f_ext_not_match(ext)
  else
    f_ok()
  no

@upload_click = (btn) ->
  t = $('#tp-modal #file')
  return no if $('#upload-button').hasClass('disabled')
  tag = t[0]
  type = t.attr('data-tp-type')
  path = t.attr('data-tp-path')
  path = '/' unless path
  files = tag.files
  if files.length
    file = files[0]
#    TODO 这里写死了的请注意
    url = "/account/third_parties/upload_url/#{type}?path=#{path}#{file.name}"

    $.ajax(
      url: url
      success: (data) ->
        file = $('#tp-modal #file')
        progress = $('#tp-modal #progress')
        file.fileupload(
            autoUpload: false
            url: data.msg
            type: 'POST'
            sequentialUploads: true
            progressall: (e, data) ->
              $('#tp-modal #progress .bar').css('width', "#{data.loaded / data.total * 100}%")
            done: ->
              progress.removeClass('progress-striped active')
              progress.addClass('progress-success')
              file.fileupload('destroy')
            fail: ->
              progress.removeClass('progress-striped active')
              progress.addClass('progress-danger')
              file.fileupload('destroy')
        )
        file.fileupload('send', {files: files})
      error: ->
        console.log('error')
    )
  no