require 'test_helper'

describe MemberEligibility do
  let(:active_coverage) do
    {
      'active' => true,
      'dependent' => true,
      'first_name' => 'SUZ',
      'group_name' => 'UNITED SERVICES AUTOMOBILE ASSOCIAT',
      'group_number' => '072781301400002',
      'member_id' => 'W111111111'
    }
  end

  let(:inactive_coverage) do
    {
      'active' => false,
      'dependent' => true,
      'first_name' => 'SUZ',
      'group_name' => 'UNITED SERVICES AUTOMOBILE ASSOCIAT',
      'group_number' => '',
      'member_id' => ''
    }
  end

  let(:invalid_coverage) do
    {
      'active': true,
      'dependent': true,
      'first_name': 'SUZ',
      'group_name': 'AETNA',
      'group_number': '22222',
      'member_id' => 'W111111111'
    }
  end

  describe '#call' do
    describe 'with active coverage' do
      it 'will be true' do
        coverage = Hashie::Mash.new(active_coverage)
        plan_sponsor = PlanSponsor.new(active_coverage)
        plan_sponsor.stub(:call, true) do
          MemberEligibility.new(coverage).call.must_equal true
        end
      end
    end

    describe 'with inactive coverage' do
      it 'will be false' do
        coverage = Hashie::Mash.new(inactive_coverage)
        MemberEligibility.new(coverage).call.must_equal false
      end
    end

    describe 'with invalid coverage' do
      it 'will be false' do
        coverage = Hashie::Mash.new(invalid_coverage)
        MemberEligibility.new(coverage).call.must_equal false
      end
    end
  end
end
