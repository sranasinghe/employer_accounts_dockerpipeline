class ResetPassword
  include ActiveModel::Model
  include ActiveModel::SecurePassword

  TOKEN_DURATION = 36.hours

  has_secure_password(validations: false)

  attr_accessor :token, :email, :member, :answer, :password_digest

  validate :validate_member_found, on: [:check_email, :check_answer]
  validate :validate_answer_correct, on: :check_answer
  validate :validate_token, on: [:token_valid, :update]
  validate :validate_password_format, on: :update
  validates :password, length: { minimum: 8, maximum: 72 }, on: :update

  delegate :reset_password_token, :reset_password_expiration, to: :member, allow_nil: true

  def initialize(token: nil, email: nil, answer: nil, password: nil)
    self.token = token
    self.email = email
    self.answer = answer
    self.password = password
  end

  def update_reset_password_token!
    member.update_reset_token!(SecureRandom.urlsafe_base64(45), TOKEN_DURATION.from_now)
  end

  def email_member
    PasswordMailer.reset_password(self).deliver_now
  end

  def notify_member!
    update_reset_password_token!
    email_member
  end

  def security_question
    member.try(:security_question).try(:question)
  end

  def security_answer
    member.try(:security_question).try(:answer)
  end

  def update
    return false unless valid?(:update)
    member.save
  end

  def member
    @member ||= Member.find_by(reset_password_token: token) if token
    @member ||= Member.find_by(email: email) if !@member && email
    @member
  end

  private

  def validate_token
    errors.add(:base, :invalid_token) unless valid_reset_password_token?
  end

  def valid_reset_password_token?
    reset_password_expiration &&
      reset_password_expiration > DateTime.current
  end

  def validate_password_format
    if password.present?
      errors.add(:password, :must_contain_uppercase) unless password[/[A-Z]/]
      errors.add(:password, :must_contain_number_or_symbol) unless password[/\W|\d/]
    end
  end

  def validate_answer_correct
    errors.add(:answer, :is_incorrect) unless answer.casecmp(security_answer.downcase).zero?
  end

  def validate_member_found
    if email.blank?
      errors.add(:email, :blank)
    elsif !(email =~ /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i)
      errors.add(:email, :invalid_format)
    elsif member.blank?
      errors.add(:email, :address_not_found)
    end
  end
end
