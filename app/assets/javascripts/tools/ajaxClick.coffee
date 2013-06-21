#PluginName = 'ajaxClick'
#DefaultOptions = {
#  ajax: 'true'
#  method: 'get'
#}
#
#$.fn[PluginName] = (options) ->
#  ops.ajax = this.attr('data-ajax')
#  ops.method = this.attr('data-method')
#  ops = $.extend({}, DefaultOptions, options)
#  if ops.ajax == 'true'
#    this.click ->
#      $.ajax(
#        url: this.attr('href')
#        type: ops.method
#        success: (data) ->
#
#      )
#      no