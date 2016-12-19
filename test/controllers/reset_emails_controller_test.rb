require 'test_helper'

describe ResetEmailsController do
  describe 'POST #find_member' do
    let(:reset_email_params) { { member_id: '1234', date_of_birth: '2001-01-01' } }

    before do
      @member = Member.new(email: 'test@testuser.com')
    end

    it 'returns a 200 if the member is found' do
      Member.stub(:find_by, @member) do
        post :find_member, reset_email: reset_email_params
        assert_response :success
      end
    end

    it 'returns a 404 if the member is not found' do
      Member.stub(:find_by, nil) do
        post :find_member, reset_email: reset_email_params
        assert_response :not_found
      end
    end
  end

  describe 'PUT #update' do
    let(:member) { Member.new(email: 'test@testuser.com') }

    it "updates the member's email with valid params" do
      def member.update_attributes(_)
      end

      find_by_with_params = ->(args) { args[:email] == 'other@testuser.com' ? nil : member }

      Member.stub(:find_by, find_by_with_params) do
        put :update, reset_email: { member_id: '1234', date_of_birth: '01-01-2001', new_email: 'other@testuser.com' }
        assert_response :no_content
      end
    end

    it "raises an exception if the member can't be found" do
      Member.stub(:find_by, nil) do
        put :update, reset_email: { member_id: '1234', date_of_birth: '01-01-2001', new_email: 'test@testuser.com' }
        assert_response :not_found
      end
    end

    it 'returns a conflict if the email address is taken' do
      Member.stub(:find_by, member) do
        put :update, reset_email: { member_id: '1234', date_of_birth: '01-01-2001', new_email: 'test@testuser.com' }
        assert_response :conflict
      end
    end

    it 'returns a bad request if data is invalid' do
      Member.stub(:find_by, member) do
        put :update, reset_email: { member_id: '1234', new_email: 'test@testuser.com' }
        assert_response :bad_request
      end
    end
  end
end
