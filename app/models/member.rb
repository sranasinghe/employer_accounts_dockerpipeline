class Member < ActiveRecord::Base
  self.primary_key = 'id'

  has_one :security_question
  accepts_nested_attributes_for :security_question
  serialize :email, CryptSerializer.new
  serialize :first_name, CryptSerializer.new
  serialize :last_name, CryptSerializer.new
  serialize :member_id, CryptSerializer.new
  serialize :date_of_birth, CryptSerializer.new

  has_secure_password

  validates :password, presence: true, on: :create
  validates :first_name, :last_name, :email, :date_of_birth, presence: true
  validates :member_id, presence: true
  validate :member_id_dob_and_name_must_be_unique, on: :create
  validate :email_must_be_unique, on: :create

  def self.authenticate!(email, password)
    member = find_by_email_or_null(email)
    member.authenticated(password)
  end

  def self.find_by_email_or_null(email)
    find_by_email(email) || Null.new
  end

  def authenticated(password)
    BCrypt::Password.new(password_digest) == password ? self : false
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def digest
    id && Digest::SHA2.hexdigest(id.to_s)
  end

  def update_reset_token!(token, expiration)
    self.reset_password_token = token
    self.reset_password_expiration = expiration
    self if save
  end

  def date_of_birth=(dob)
    dob = dob.to_s.to_date
    dob = dob.strftime('%Y-%m-%d') if dob
    super(dob)
  end

  def active_coverage?
    coverage_status.active

    # refer to git commit regarding MemberEligibility
    # MemberEligibility.new(coverage_status).call
  end

  private

  def member_id_dob_and_name_must_be_unique
    if Member.find_by(member_id: member_id, date_of_birth: date_of_birth, first_name: first_name)
      errors.add(:member, 'ID, Date of Birth, and name has already been registered')
    end
  end

  def email_must_be_unique
    errors.add(:email, 'has already been taken') if Member.find_by(email: email)
  end

  def coverage_status
    CoverageStatus.fetch!(member_id: member_id, member_dob: date_of_birth, first_name: first_name)
  end
end
