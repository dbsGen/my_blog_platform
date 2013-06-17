# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

@uploadDone = (request) ->
  Messenger().post('模板发布成功');
  $('#templates-modal').model('hide');

@uploadFail = (request) ->
  Messenger().post(
    type: 'error'
    message: JSON.parse(request.responseText).msg
  )

