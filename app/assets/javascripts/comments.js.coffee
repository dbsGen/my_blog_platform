# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
#= require articles/content_add_tp_js

@post_comment = (tag)->
  try
    btn = $(tag)
    btn.attr('disabled', true)
    console.log(btn.attr('href'))
    el = $('#article-edit')
    ed = $('#article-edit .edit_element:first')
    $.ajax(
      type: 'post'
      url: btn.attr('href')
      data: {
        article: el.attr('article')
        reply_to: el.attr('reply_to')
        elements: [{
                   template_name: ed.attr('template_name')
                   content: $.add_tp($("##{ed.attr('for')}").val())
                   }]
      }

      success: (data)->
        Messenger().post(data.msg)
        btn.attr('disabled', false)
      error: (request)->
        data = eval("(#{request.responseText})")
        Messenger().post(
          message: data.msg
          type: 'error'
        )
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
