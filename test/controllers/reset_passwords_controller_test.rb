require 'test_helper'

describe ResetPasswordsController do
  before do
    @member = Member.new(email: 'test@test.com', first_name: 'John', last_name: 'Doe',
                         password_digest: BCrypt::Password.create('test_password'),
                         date_of_birth: '07-04-1980',
                         member_id: 'W1111111',
                         security_question_attributes: { question: 'some question', answer: 'Success Answer' })
    @member.save(validate: false)
    Member.stubs(:find_by).returns(@member)
    def @member.update_attributes(_attr)
      true
    end
  end

  describe 'GET #get_question' do
    let(:invalid_email_message) { { 'errors' => 'The email address was not found or is invalid' } }
    let(:question) { { 'question' => 'Some question' } }

    it 'returns an error if the email is blank' do
      get :get_question, email: 'jfklasdkfja'
      response.status.must_equal 400
      JSON.parse(response.body).must_equal invalid_email_message
      JSON.parse(response.body).wont_be_nil
    end

    it 'returns the question json for a good email address' do
      get :get_question, email: 'test@test.com'
      response.status.must_equal 200
      JSON.parse(response.body).must_equal question
      JSON.parse(response.body).wont_be_nil
    end
  end

  describe 'POST #answer_question' do
    it 'returns a success and a messsage on successful answer' do
      post :answer_question, reset_password: { email: 'test@test.com', answer: 'Success Answer' }
      response.status.must_equal 201
    end

    it 'still shows success even if the answer is wrong' do
      post :answer_question, reset_password: { email: 'test@test.com', answer: 'Bogus Answer' }
      response.status.must_equal 201
    end
  end

  describe 'with a valid reset password token' do
    before do
      @member.reset_password_token = SecureRandom.urlsafe_base64(45)
      @member.reset_password_expiration = 2.hours.from_now
    end

    describe 'get #verify_token' do
      it 'is successful' do
        get :verify_token, token: @member.reset_password_token
        response.status.must_equal 202
      end
    end

    describe 'PUT #update' do
      it 'renders the completed view when successful' do
        put :update, reset_password: { token: @member.reset_password_token, password: 'Password!', password_confirmation: 'Password!' }
        response.status.must_equal 200
        response.body.must_be :blank?
      end

      it 'returns a bad request if passwords dont match' do
        put :update, reset_password: { token: @member.reset_password_token, password: 'test_password', password_confirmation: 'different password' }
        response.status.must_equal 400
      end
    end
  end

  describe 'when the reset password token is invalid' do
    describe 'GET #verify_reset_password_token' do
      it 'returns an error status' do
        get :verify_token, token: 'invalid token'
        response.status.must_equal 401
      end
    end

    describe 'PUT #update' do
      it 'responds with unauthorized status' do
        put :update, reset_password: { token: 'invalid token', password: 'TestPassword1', password_confirmation: 'TestPassword1' }
        response.status.must_equal 401
      end
    end
  end
end
