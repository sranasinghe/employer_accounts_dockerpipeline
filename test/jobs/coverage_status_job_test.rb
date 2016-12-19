require 'test_helper'

describe CoverageStatusJob do
  before do
    @member = Member.create!(
      date_of_birth: Time.now,
      member_id: 'w123',
      password: 'foobar',
      first_name: 'Johnny',
      last_name: 'Appleseed',
      email: 'test@testuser.com',
      reset_password_token: 'abc123',
      password_digest: BCrypt::Password.create('test_password'),
      security_question_attributes: { question: 'some question', answer: 'Success Answer' }
    )

    @coverage_params = {
      member_id: @member.member_id,
      member_dob: @member.date_of_birth,
      first_name: @member.first_name
    }
  end

  it 'fetches coverage status' do
    CoverageStatus.expects(:fetch!).with(@coverage_params).returns(true)
    assert CoverageStatusJob.new.perform(@member)
  end
end
