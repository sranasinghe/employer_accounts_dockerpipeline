class ResetPasswordsController < ApplicationController
  respond_to :json

  def get_question
    @reset_password = ResetPassword.new(email: params[:email])
    if @reset_password.valid?(:check_email)
      render json: { question: @reset_password.security_question }
    else
      render json: { errors: 'The email address was not found or is invalid' }, status: :bad_request
    end
  end

  def answer_question
    @reset_password = ResetPassword.new(reset_password_params)
    @reset_password.notify_member! if @reset_password.valid?(:check_answer)
    head :created
  end

  def verify_token
    @reset_password = ResetPassword.new(token: params[:token])
    if @reset_password.valid?(:token_valid)
      head :accepted
    else
      head :unauthorized
    end
  end

  def update
    @reset_password = ResetPassword.new(update_password_params)

    head(:unauthorized) && return if @reset_password.invalid?(:token_valid)

    @reset_password.password = params[:reset_password][:password]

    if @reset_password.update
      head :ok
    else
      head :bad_request
    end
  end

  private

  def reset_password_params
    params.require(:reset_password).permit(:email, :answer).symbolize_keys
  end

  def update_password_params
    params.require(:reset_password).permit(:token, :password).symbolize_keys
  end
end
