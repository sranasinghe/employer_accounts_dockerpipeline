class PasswordMailer < ActionMailer::Base
  def reset_password(reset_password)
    @token = reset_password.reset_password_token
    @member = Member.find_by(reset_password_token: @token)
    mail(to: reset_password.email, subject: 'reset password')
  end
end
