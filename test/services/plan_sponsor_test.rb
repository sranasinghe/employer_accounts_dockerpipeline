require 'test_helper'

describe PlanSponsor do
  let(:eligible_member_coverage_status_response) do
    {
      'active': true,
      'dependent': true,
      'first_name': 'SUZ',
      'group_name': 'UNITED SERVICES AUTOMOBILE ASSOCIAT',
      'group_number': '',
      'member_id': 'W111111111'
    }
  end

  let(:invalid_group_name_response) do
    {
      'active': true,
      'dependent': true,
      'first_name': 'SUZ',
      'group_name': 'AETNA',
      'group_number': '',
      'member_id': 'W111111111'
    }
  end

  describe '#call' do
    context 'plan is middle market' do
      it 'returns true' do
        coverage = Hashie::Mash.new(eligible_member_coverage_status_response)
        plan_sponsor = PlanSponsor.new(coverage)
        plan_sponsor.stub(:middle_market?, true) do
          plan_sponsor.call.must_equal true
        end
      end
    end

    context 'is not middle market' do
      it 'returns false' do
        coverage = Hashie::Mash.new(invalid_group_name_response)
        plan_sponsor = PlanSponsor.new(coverage)
        plan_sponsor.call.must_equal false
      end
    end
  end
end
