require 'active_record'

class PlanTable < ActiveRecord::Base
  establish_connection("#{ENV['PLANS_DATABASE_URL']}").connection()
  self.table_name = 'plans'

  def readonly?
    true
  end
end

class Plan
  attr_accessor :coverage_status

  def initialize(coverage_status)
    @coverage_status = coverage_status
  end

  def call
    group_number_in_boooooost?
  end

  private

  attr_accessor :query_result

  def member_group_number
    coverage_status[:group_number]
  end

  def query_plan_table
    PlanTable.where("'#{member_group_number}' = ANY(group_numbers)")
  end

  def group_number_in_boooooost?
    @query_result = query_plan_table

    @query_result.empty? ? false : true
  end
end
