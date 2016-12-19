require 'test_helper'

describe Plan do
  let(:eligible_member_coverage_status_response) do
    {
      'active': true,
      'dependent': true,
      'first_name': 'SUZ',
      'group_name': 'HSA Active',
      'group_number': '072781301400002',
      'member_id': 'W111111111'
    }
  end

  let(:invalid_group_number_response) do
    {
      'active': true,
      'dependent': true,
      'first_name': 'SUZ',
      'group_name': 'AETNA',
      'group_number': '11111',
      'member_id': 'W111111111'
    }
  end

  describe '#call' do
    context 'with a valid group_number' do
      it 'returns true' do
        coverage = Hashie::Mash.new(eligible_member_coverage_status_response)
        plan = Plan.new(coverage)
        plan.call.must_equal true
      end
    end

    context 'with an invalid group_number' do
      it 'returns false' do
        coverage = Hashie::Mash.new(invalid_group_number_response)
        plan = Plan.new(coverage)
        plan.call.must_equal false
      end
    end
  end
end
