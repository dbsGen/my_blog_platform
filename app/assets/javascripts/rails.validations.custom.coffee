window.ClientSideValidations.formBuilders['ActionView::Helpers::FormBuilder'] = {
  add: (element, settings, message) ->
#    if (element.data('valid') != false && jQuery('label.message[for="' + element.attr('id') + '"]')[0] == undefined)
#      error_label = jQuery('<label class="message"></label>').attr('for', element.attr('id'))
#
#      element.attr('autofocus', false) if (element.attr('autofocus'))
#      element.after(error_label);
#
#    jQuery('label.message[for="' + element.attr('id') + '"]').text(message);
#      alert "add : \nelement is : #{typeof(element)}\nsettings is : #{typeof(settings)}\nmessage is #{typeof(message)}"
    sup = element.parents('div.control-group')
    sup.addClass('error')
    sup.find('span.help-inline').remove()
    element.after("<span class='help-inline'>#{message}</span>")
  remove: (element, settings) ->
#    jQuery('label[for="' + element.attr('id') + '"].message').remove();
    sup = element.parents('div.control-group')
    sup.removeClass('error')
    sup.find('span.help-inline').remove()
}
#window.ClientSideValidations.validators.local['email'] = (element, options) ->
#  # Your validator code goes in here
#  if (element.val().length < 6)
#    # When the value fails to pass validation you need to return the error message.
#    # It can be derived from validator.message
#    return options.message