$(document).ready ->
  s = location.href
  s = s.substr(s.indexOf('?') + 1)
  arr = s.split('&')
  query = {}
  for q in arr
    objs = q.split('=')
    if objs.length == 2
      query[objs[0]] = objs[1]

  Messenger().post(
    type: 'error'
    message: decodeURI(query.err)
  ) if query.err
  Messenger().post(decodeURI(query.msg)) if query.msg
  $('#redirect').val(decodeURI(query.red)) if query.red


