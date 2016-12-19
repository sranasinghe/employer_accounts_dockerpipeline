class MemberEligibility
  attr_reader :coverage_status

  def initialize(coverage_status)
    @coverage_status = coverage_status
  end

  def call
    plan_boooooost?
  end

  private

  def plan_boooooost?
    if plan_active?
      PlanSponsor.new(coverage_status).call
    else
      return false
    end
  end

  def plan_active?
    coverage_status.active
  end
end
