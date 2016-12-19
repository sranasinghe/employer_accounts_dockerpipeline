class ResetEmail
  include ActiveModel::Model
  include Virtus.model

  attribute :member_id, String
  attribute :date_of_birth, String
  attribute :new_email, String

  delegate :full_name, to: :member

  validates :member_id, :date_of_birth, presence: true
  validates :new_email, presence: true, on: :update
  validates_format_of :new_email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, on: :update

  def update_email!
    return :invalid_data unless valid?(:update)
    return :member_not_found unless member
    return :email_taken unless email_unique?
    old_email = member.email
    member.update_attribute(:email, new_email)

    ResetEmailMailer.new_email_notification(self).deliver_now
    ResetEmailMailer.old_email_notification(self, old_email).deliver_now

    :email_updated
  end

  def member_found?
    !member.nil?
  end

  private

  def member
    Member.find_by(member_id: member_id, date_of_birth: date_of_birth)
  end

  def email_unique?
    if new_email && Member.find_by(email: new_email)
      false
    else
      true
    end
  end
end
