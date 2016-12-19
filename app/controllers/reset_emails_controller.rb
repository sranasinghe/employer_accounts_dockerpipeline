class ResetEmailsController < ApplicationController
  def find_member
    @reset_email = ResetEmail.new(find_member_params)
    if @reset_email.member_found?
      head :ok
    else
      head :not_found
    end
  end

  def update
    @reset_email = ResetEmail.new(update_email_params)
    case @reset_email.update_email!
    when :email_updated
      head :no_content
    when :member_not_found
      head :not_found
    when :email_taken
      head :conflict
    when :invalid_data
      head :bad_request
    end
  end

  private

  def find_member_params
    params.require(:reset_email).permit(:member_id, :date_of_birth)
  end

  def update_email_params
    params.require(:reset_email).permit(:member_id, :date_of_birth, :new_email)
  end
end
