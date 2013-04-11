$.extend(
  add_tp: (content) ->
    imgs = content.match(/<img[^>]+src=[^>]+tp_id=[^>]+>/)
    nc = new String(content)
    if imgs and imgs.length > 0
      for img in imgs
        src = img.match(/src='[^']+'/)
        if src
          url = src[0].match(/'[^']+'/)[0]
          url = eval(url)
        else
          src = img.match(/src="[^"]+"/)
          if src
            url = src[0].match(/"[^"]+"/)[0]
            url = eval(url)
        index = url.indexOf('?')
#        TODO 请注意这里是写死了的
        if index != -1 and url.indexOf('https://pcs.baidu.com/rest/2.0/pcs/file') != -1
          arr = url.substr(index + 1).split('&amp;')
          for str in arr
            kv = str.split('=')
            if kv.length == 2
              if kv[0] == 'tp_id'
                tp_id = kv[1]
              if kv[0] == 'path'
                path = kv[1]
        if tp_id and path
          nc = nc.replace(img, img.replace(src, "data-tp='baidu' data-tp-id='#{tp_id}' data-path='#{path}'"))
      nc
)