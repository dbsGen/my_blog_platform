dequeue = ->
  return if document.ajax_loading or document.ajax_queue.length == 0
  document.ajax_loading = true
  ops = document.ajax_queue.shift()
  if typeof(ops) == 'function'
    ops.apply()
    document.ajax_loading = false
    dequeue()
  else
    request = $.ajax(ops)
    document.ajax_doing = request
    request.complete ->
      document.ajax_loading = false
      document.ajax_doing = null
      dequeue()

$.extend(
  ajax_q: (options) ->
    if !document.ajax_queue
      document.ajax_queue = []

    document.ajax_queue.push(options)
    dequeue()
  ajax_stop: ->
    if document.ajax_doing
      document.ajax_doing.abort()
      document.ajax_doing = null
    document.ajax_queue = []
  ajax_loading: ->
    document.ajax_loading
)