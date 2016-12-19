require_relative '../test_helper.rb'

describe Member do
  before do
    @member = Member.new(
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
    )
  end

  subject { @member }

  it { subject.respond_to?(:first_name).must_equal true }
  it { subject.respond_to?(:digest).must_equal true }

  describe '#digest' do
    let(:expected) { Digest::SHA2.hexdigest(id.to_s) }

    describe "when the member's ID is nil" do
      let(:id) { nil }
      it { subject.digest.must_equal nil }
    end

    describe 'when the member has an ID' do
      let(:id) { subject.id }

      before do
        subject.save
      end

      it { subject.digest.must_equal expected }
    end
  end

  describe 'creation' do
    it 'exists' do
      @member.save
      persisted_member = Member.find(@member.id)
      persisted_member.member_id.must_equal @member.member_id
    end
  end

  describe 'validation' do
    let(:subject) do
      Member.new(first_name: 'John', last_name: 'Doe', email: 't@a.com', password: 'aaa', member_id: 'W111', date_of_birth: '1989-01-01')
    end

    [:first_name, :last_name, :email, :password, :member_id, :date_of_birth].each do |field|
      it "requires the #{field} to be present" do
        subject.valid?.must_equal true
        subject.send("#{field}=", nil)
        subject.valid?.must_equal false
      end
    end

    context 'duplicate accounts' do
      before do
        @member.save!
      end
      it 'allows the same member-id to be used multiple times' do
        dependent = Member.new(@member.attributes)
        dependent.date_of_birth = '01-01-1990'
        dependent.email = 'kid@test.com'
        dependent.password = 'bang'
        dependent.valid?.must_equal true
      end
      it 'doesnt allow duplicates by member-id + dob + first name' do
        dependent = Member.new(@member.attributes)
        dependent.password = 'bang'
        dependent.valid?.must_equal false
      end
    end

    context 'unique email' do
      before do
        @member.save!
      end
      it "doesn't allow user to register with an email that is already is use" do
        registering_user = Member.new(@member.attributes)
        registering_user.date_of_birth = '01-01-1990'
        registering_user.password = 'bang'
        registering_user.valid?.must_equal false
      end
    end

    context 'date formatting' do
      it 'fixes non-padded dates' do
        @member.date_of_birth = '1-1-1990'
        @member.save
        persisted_member = Member.find(@member.id)
        persisted_member.date_of_birth.must_equal '1990-01-01'
      end

      it 'works for padded dates' do
        @member.date_of_birth = '1990-10-10'
        @member.save
        persisted_member = Member.find(@member.id)
        persisted_member.date_of_birth.must_equal '1990-10-10'
      end
    end
  end
end
