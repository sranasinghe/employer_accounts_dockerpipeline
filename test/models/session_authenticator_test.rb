require 'test_helper'

describe SessionAuthenticator do
  before do
    @member = Member.new.tap do |member|
      member.save(validate: false)
    end
  end

  it 'returns false unless session has a :current_user_digest' do
    SessionAuthenticator.authenticate(last_accessed: 5.minutes.ago).must_equal false
  end

  it 'returns false unless session has a :last_accessed' do
    SessionAuthenticator.authenticate(current_user_id: @member.id).must_equal false
  end

  it 'returns false when :last_accessed is more than 30 minutes ago' do
    SessionAuthenticator.authenticate(last_accessed: 31.minutes.ago).must_equal false
  end

  it 'returns the member when all data is valid' do
    SessionAuthenticator.authenticate(current_user_id: @member.id, last_accessed: 5.minutes.ago).must_equal @member
  end
end
