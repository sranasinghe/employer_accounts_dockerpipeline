require 'test_helper'

describe MemberAuthorizer do
  let(:member) { Member.new(member_params) }

  let(:base_member_params) do
    {
      id: 1,
      first_name: 'Jon',
      last_name: 'Snow',
      email: 'test@testuser.com',
      password: 'foo',
      member_id: 'W1111111',
      date_of_birth: '01-01-1980',
      security_question_attributes: {
        question: 'Who let the dogs out?',
        answer: 'woof woof woof woof woof'
      }
    }
  end
  let(:member_params) { base_member_params }

  subject { MemberAuthorizer.new(member) }

  it { subject.respond_to?(:status).must_equal true }
  it { subject.respond_to?(:json).must_equal true }

  describe '#json' do
    describe 'when the member is not termed' do
      before do
        member.termed.must_be_nil
      end

      it { subject.json.wont_match(/errors/) }
      it { subject.json.must_match(/member_id/) }
      it { subject.json.must_match(/digest/) }
    end

    describe 'when the member has been termed' do
      let(:member_params) { base_member_params.merge(termed: true) }

      it { subject.json[:errors].wont_equal nil }
    end
  end
end
