#= require articles/content_add_tp_js
#= require jquery.baidu
#= require third_party

$(document).ready ->
  this.add_template = (btn) ->
    tn = btn.attr('template_name')
    elms = $('#edit_content .edit_element')
    s = $('#edit_content .edit_element').size()
    index = 0
    for elm in elms
      if $(elm).attr('template_name') == tn
        index += 1

    $.ajax(
      url: btn.attr('href') + '.js'
      type: 'get'
      data: "index=#{index}"
      success: (data) ->
        eval(data)
        console.log(str)
        if s == 0
          $('#edit_content').html(str)
        else
          $(str).appendTo('#edit_content')
      error: ->
        Messenger().post(
          type: 'error'
          message: '添加失败'
        )
    )

  submit = (btn ,method, success, error) ->
    if $('#title').val().trim() == ''
      Messenger().post(
        type: 'error'
        message: '标题不能为空!'
      )
      return no

    elements = $('#edit_content .edit_element');
    d = []

    for element in elements
      e = $(element)
      content = $("##{e.attr('for')}").val()
      continue if content == null or content.length == 0
      d.push({
             template_name: e.attr('template_name')
             content: $.add_tp(content)
             })

    if d.length == 0
      Messenger().post(
        type: 'error'
        message: '内容不能为空.'
      )
      return no

    btn.attr('disabled', true)
    $.ajax(
      url: btn.attr('href')
      type: method
      data: {
      title: $('#title').val()
      elements: d
      }
      success: success
      error: error
    )

  $('#post').click ->
    try
      btn = $(this)
      submit(btn,'post',
      (data) ->
        Messenger().post(data.msg)
        if data.redirect_url != null
          setTimeout(->
            window.location.href = data.redirect_url
          , 2000)
        btn.attr('disabled', false)
      ,
      (r)->
        obj = eval("(#{r.responseText})")
        Messenger().post(
          type: 'error'
          message: obj.msg
        )
        btn.attr('disabled', false)
      )
    catch e
      console.log e
    no

  $('#update').click ->
    btn = $(this)
    submit(btn,'put',
    (data) ->
      Messenger().post(data.msg)
      btn.attr('disabled', false)
    ,
    (r)->
      obj = eval("(#{r.responseText})")
      Messenger().post(
        type: 'error'
        message: obj.msg
      )
      btn.attr('disabled', false)
    )
    no

  this.remove_tag = (t) ->
    $(t).parents('.edit_element').remove()
    no