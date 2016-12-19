class ResetEmailMailer < ActionMailer::Base
  def new_email_notification(reset_email)
    @reset_email = reset_email
    mail(to: reset_email.new_email, subject: 'reset email notification')
  end

  def old_email_notification(reset_email, old_email)
    @reset_email = reset_email
    mail(to: old_email, subject: 'reset email notification')
  end
end
