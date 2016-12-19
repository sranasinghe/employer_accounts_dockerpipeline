class CoverageStatusJob
  include SuckerPunch::Job

  def perform(member)
    params = { member_id: member.member_id,
               member_dob: member.date_of_birth,
               first_name: member.first_name }

    ::CoverageStatus.fetch!(params)
  end
end
