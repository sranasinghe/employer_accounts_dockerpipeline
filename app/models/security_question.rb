class SecurityQuestion < ActiveRecord::Base
  self.table_name = 'security_questions'
  serialize :answer, CryptSerializer.new
  serialize :question, CryptSerializer.new

  belongs_to :member

  validates :answer, presence: true

  validates :question, presence: true

  def question
    self[:question].capitalize if question?
  end
end
