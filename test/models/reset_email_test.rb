require 'test_helper'

describe ResetEmail do
  let(:member) { Member.new(email: 'test@testuser.com') }

  describe 'validation' do
    let(:re) { ResetEmail.new(date_of_birth: Time.now, member_id: '123') }

    it 'requires member id' do
      re.member_id = nil
      re.must_be :invalid?
      re.errors.keys.must_equal [:member_id]
    end

    it 'is invalid if the email is already taken' do
      Member.stub(:find_by, member) do
        re.new_email = 'test@testuser.com'
        re.send(:email_unique?).must_equal false
      end
    end

    it 'requires date of birth' do
      re.date_of_birth = nil
      re.must_be :invalid?
      re.errors.keys.must_equal [:date_of_birth]
    end

    it 'is valid if the member is found and both dob and id are provided' do
      Member.stub(:find_by, member) do
        re.must_be :valid?
      end
    end

    it 'is invalid if the new email address is invalid' do
      Member.stub(:find_by, member) do
        re.new_email = 'bademail@'
        re.valid?(:update).must_equal false
        re.new_email = 'goodemail@test.com'
        re.valid?(:update).must_equal true
      end
    end
  end

  describe '#update_email!' do
    let(:re) { ResetEmail.new(date_of_birth: Time.now, member_id: '123', new_email: 'other@testuser.com') }
    let(:transp_find_by_stub) { ->(args) { args[:email] == 'other@testuser.com' ? nil : member } }

    it 'changes the email address for the member' do
      def member.update_attributes(_)
      end
      Member.stub(:find_by, transp_find_by_stub) do
        re.update_email!.must_equal :email_updated
      end
    end

    it 'sends a notification and confirmation email' do
      def member.update_attributes(_)
      end

      Member.stub(:find_by, transp_find_by_stub) do
        re.update_email!
        ActionMailer::Base.deliveries.wont_be :empty?
      end
    end
  end
end
