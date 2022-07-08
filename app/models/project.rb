class Project < ApplicationRecord
  belongs_to :center

  def self.getProjectList()
  	Project.select("projects.*, centers.center_name, locations.location_name")
  	.select('(select group_concat(p_alias) from project_aliases where project_aliases.project_id =  projects.id) as alias')
  	.select("group_concat(distinct users.email) as users_emails")
    .select("
      group_concat( distinct
            CONCAT(
              if (
                users.first_name is null or users.last_name Is null, 
                LEFT (users.email, 2),
                concat(
                  LEFT (users.first_name, 1), 
                  LEFT (users.last_name, 1)
                )
            ), ',', users.email
            )
             
        separator ';') as users_detail
      ")
    .select("count(distinct case when reports.r_status_id != 6 then reports.id end) as open_reports")
    .select("count(distinct case when reports.r_status_id = 6 then reports.id end) as closed_reports")
  	# .select("group_concat(case when users.first_name is null or users.last_name is null then email else concat (users.first_name, ' ', users.last_name) ene ) as users")
  	.joins(:center)
  	.joins('left join locations ON locations.id = projects.location_id')
    .joins("left join user_has_projects ON user_has_projects.project_id = projects.id")
  	.joins("left join users ON user_has_projects.user_id = users.id")
    .joins("left join reports ON reports.project_id = projects.id")
    .group("projects.id")

  end
end
