require 'test_helper'

describe PasswordMailer do
  before do
    @member = Member.create!(
      date_of_birth: Time.now,
      member_id: 'w123',
      password: 'foobar',
      first_name: 'Johnny',
      last_name: 'Appleseed',
      email: 'test@testuser.com',
      reset_password_token: 'abc123',
      password_digest: BCrypt::Password.create('test_password'),
      security_question_attributes: { question: 'some question', answer: 'Success Answer' }
    )
    @reset_password = OpenStruct.new(reset_password_token: @member.reset_password_token, email: @member.email)
  end

  it 'creates password reset emails' do
    mail = PasswordMailer.reset_password(@reset_password).deliver_now
    mail.to.must_equal [@member.email]
    mail.from.must_equal [Rails.configuration.action_mailer.default_options[:from]]
  end
end
