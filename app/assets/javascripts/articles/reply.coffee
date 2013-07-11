@post_comment = (tag)->
  try
    btn = $(tag)
    btn.attr('disabled', true)
    el = $('#article-edit')
    ed = $('#article-edit .edit_element:first')
    e = $("##{ed.attr('for')}")
    $.ajax(
      type: 'post'
      url: $('#send-button').attr('href')
      data: {
        article: el.attr('article')
        reply_to: el.attr('reply_to')
        elements: [{
          template: ed.attr('template')
          content: $.add_tp(e.val())
        }]
      }

      success: (data)->
        eval(data)
        btn.attr('disabled', false)
        e.data("wysihtml5").clear()
      error: (request)->
        try
          data = eval("(#{request.responseText})")
          Messenger().post(
            message: data.msg
            type: 'error'
          )
        catch e
          console.error(e)
        btn.attr('disabled', false)
    )
  catch e
    console.log(e)
    btn.attr('disabled', false)
  return no
  no

@reply = (reply_id, flood) ->
  $('#article-edit').attr('reply_to', reply_id)
  $('#article-edit #article-replay').html("&gt;&gt; ##{flood} &nbsp;&nbsp;<a href='javascript:void(0);' onclick='remove_reply()'><i class='icon-remove-circle'></i></a>")
  yes

@remove_reply = ->
  $('#article-edit').attr('reply_to', '')
  $('#article-edit #article-replay').html('')
  no

@extend_reply = (tag) ->
  btn = $(tag)
  for_id = btn.attr('for')
  $("##{for_id}").clone().replaceAll(btn)