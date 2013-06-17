class Email < ActionMailer::Base
  default from: 'no_reply@mingp.net', content_type: 'text/html'

  def confirm(recipient, subject, url)
    @link = url
    mail(to: recipient, subject: subject) do |format|
      format.html {render layout: 'email'}
    end
  end

  def findback(recipient, subject, url)
    @link = url
    mail(to: recipient, subject: subject) do |format|
      format.html { render layout: 'email' }
    end
  end
end
