class Project < ApplicationRecord
  belongs_to :center

  def self.getProjectList()
  	Project.select("projects.*, centers.center_name, locations.location_name")
  	.select('(select group_concat(p_alias) from project_aliases where project_aliases.project_id =  projects.id) as alias')
  	.select('(select count(*) from reports where reports.project_id = projects.id and reports.r_status_id  = 5) as open_reports')
  	.select('(select count(*) from reports where reports.project_id = projects.id and reports.r_status_id  = 5) as closed_reports')
  	# .select("group_concat(distinct users.email) as users_emails")
  	# .select("group_concat(case when users.first_name is null or users.last_name is null then email else concat (users.first_name, ' ', users.last_name) ene ) as users")
  	.joins(:center)
  	.joins('left join locations ON locations.id = projects.location_id')
  	# .joins("left join user_has_project ON user_has_project.project_id = projects.id")
  	# .joins("left join users ON user_has_project.user_id = users.id")

  end
end
