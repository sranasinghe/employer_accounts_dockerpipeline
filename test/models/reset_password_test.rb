require 'test_helper'

describe ResetPassword do
  before do
    @member = Member.new(email: 'test@testuser.com', password_digest: BCrypt::Password.create('test_password'), security_question_attributes: { question: 'some question', answer: 'Success Answer' })
    Member.stubs(:find_by).returns(@member)
    def @member.update_attributes(_attr)
    end
  end

  describe 'with a member found by email' do
    let(:email_addr) { 'test@testuser.com' }
    let(:rp) { ResetPassword.new(email: email_addr) }

    it "sets the member's email" do
      rp.email.must_equal @member.email
    end

    it "gets the member's security question" do
      rp.security_question.must_equal 'Some question'
    end

    it 'is invalid if the answer is incorrect' do
      rp.answer = 'Incorrect Answer'
      rp.valid?(:check_answer).must_equal false
      rp.errors.added?(:answer, :is_incorrect).must_equal true
    end

    describe '#notify_member!' do
      it 'updates the password expiration and emails the member' do
        curr_time = Time.now
        ResetPassword::TOKEN_DURATION.stub(:from_now, curr_time) do
          rp.notify_member!
          rp.reset_password_token.wont_be :nil?
          rp.reset_password_expiration.wont_be :nil?
          rp.reset_password_expiration.to_i.must_equal curr_time.to_i
          ActionMailer::Base.deliveries.wont_be :empty?
        end
      end
    end
  end

  describe 'without valid member info' do
    it 'adds a validation error if the email is not found' do
      Member.stubs(:find_by).returns(nil)
      rp = ResetPassword.new(email: 'invalid@test.com')
      rp.valid?(:check_email).wont_equal true
      rp.errors.added?(:email, :address_not_found).must_equal true
    end

    it 'adds a validation error if the email is blank' do
      rp = ResetPassword.new(email: nil)
      rp.valid?(:check_email).wont_equal true
      rp.errors.added?(:email, :blank).must_equal true
    end

    it 'adds a validation error if the email format is invalid' do
      rp = ResetPassword.new(email: 'foo@')
      rp.valid?(:check_email).wont_equal true
      rp.errors.added?(:email, :invalid_format).must_equal true
    end
  end

  describe '#member' do
    before do
      @member.reset_password_token = SecureRandom.urlsafe_base64(45)
    end

    it 'finds a member if the token is non-expired' do
      @member.reset_password_expiration = (ResetPassword::TOKEN_DURATION - 2.hours).ago
      rp = ResetPassword.new(token: @member.reset_password_token)
      rp.member.wont_be_nil
    end

    it 'is invalid if the token is expired' do
      @member.reset_password_expiration = (ResetPassword::TOKEN_DURATION + 1.hours).ago
      rp = ResetPassword.new(token: @member.reset_password_token)
      rp.valid?(:token_valid).must_equal false
      rp.errors.added?(:base, :invalid_token).must_equal true
    end
  end

  describe '#update' do
    it 'is invalid if the password is too short' do
      rp = ResetPassword.new(password: 'Short')
      rp.valid?(:update).must_equal false
      rp.errors.added?(:password, :too_short).must_equal true
    end

    it 'is invalid if the password is too long' do
      long_pw = (0..72).map { |_x| 'X' }.join.to_s
      rp = ResetPassword.new(password: long_pw)
      rp.valid?(:update).must_equal false
      rp.errors.added?(:password, :too_long).must_equal true
    end

    it 'is invalid if the password does not contain an uppercase letter' do
      rp = ResetPassword.new(password: 'lowercasepw')
      rp.valid?(:update).must_equal false
      rp.errors.added?(:password, :must_contain_uppercase).must_equal true
    end

    it 'is invalid if the password does not contain a symbol' do
      rp = ResetPassword.new(password: 'Password')
      rp.valid?(:update).must_equal false
      rp.errors.added?(:password, :must_contain_number_or_symbol).must_equal true
    end

    it 'is invalid if the token is expired' do
      @member.reset_password_expiration = (ResetPassword::TOKEN_DURATION + 1.hours).ago
      rp = ResetPassword.new(token: @member.reset_password_token,
                             password: 'Password!')
      rp.update.must_equal false
      rp.errors.added?(:base, :invalid_token).must_equal true
    end
  end
end
