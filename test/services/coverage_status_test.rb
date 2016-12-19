require 'test_helper'

describe CoverageStatus do
  let(:member) do
    Member.new(email: 'test@user.com',
               member_id: 'WM111111111',
               date_of_birth: '1980-01-01',
               password_digest: BCrypt::Password.create('test_password'))
  end

  let(:member_hash) { { member_id: member.member_id, member_dob: member.date_of_birth, dependent_first_name: member.first_name } }

  describe '#fetch!' do
    subject { CoverageStatus.new(member_id: member.member_id, member_dob: member.date_of_birth, first_name: member.first_name).fetch! }

    let(:wm_signature) { 'a signature' }

    let(:headers) do
      {
        'Content-Type' => 'application/json'
      }
    end

    context 'the member has active coverage' do
      let(:active_coverage) do
        {
          'coverage_status' =>
          {
            'active' => true,
            'group_name' => 'THE HOME DEPOT',
            'group_number' => '001500105200004',
            'member_id' => 'W111111'
          },
          'meta' =>
          {
            'timestamp' => DateTime.now.utc
          }
        }.to_json
      end

      before do
        stub_request(:post, "#{ENV['BENEFITS_URL']}/api/coverage_status")
          .to_return(status: 200, body: active_coverage, headers: {})
      end

      it 'returns a populated object from the benefits api' do
        subject.active.must_equal true
        subject.member_id.must_equal 'W111111'
      end

      it 'removes blankspace from the member id' do
        subject = CoverageStatus.new(member_id: 'W111 1111 111', member_dob: member.date_of_birth, first_name: member.first_name)
        subject.member_id.must_equal 'W1111111111'
      end
    end

    context 'the member has inactive coverage' do
      before do
        stub_request(:post, "#{ENV['BENEFITS_URL']}/api/coverage_status")
          .to_return(status: 401, body: inactive_coverage, headers: {})
      end

      let(:inactive_coverage) do
        {
          'coverage_status' =>
          {
            'active' => false,
            'message' => 'Coverage not found for member'
          },
          'meta' =>
          {
            'timestamp' => DateTime.now.utc
          }
        }.to_json
      end

      it 'returns inactive coverage' do
        subject.active.must_equal false
      end
    end

    context 'benefits API is unavailable' do
      before do
        stub_request(:post, "#{ENV['BENEFITS_URL']}/api/coverage_status").to_return(status: 500)
      end
      it 'raises an error' do
        -> { subject }.must_raise StandardError
      end
    end
  end
end
