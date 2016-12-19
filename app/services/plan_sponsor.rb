require 'active_record'

class PlanSponsorTable < ActiveRecord::Base
  establish_connection("#{ENV['PLANS_DATABASE_URL']}").connection()
  self.table_name = 'plan_sponsors'

  def readonly?
    true
  end
end

class PlanSponsor
  attr_accessor :coverage_status

  def initialize(coverage_status)
    @coverage_status = coverage_status
  end

  def call
    plan_sponsor_in_booooost?
  end

  private

  attr_accessor :query_result

  def group_name
    coverage_status[:group_name]
  end

  def middle_market?
    query_result.flatten.include? true
  end

  def plan_sponsor_in_booooost?
    @query_result = PlanSponsorTable.where(sponsor_identifier: group_name).pluck(:base_product)

    return false if @query_result.empty?

    middle_market? ? true : Plan.new(coverage_status).call
  end
end
