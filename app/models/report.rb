class Report < ApplicationRecord
  belongs_to :r_type
  belongs_to :r_method
  belongs_to :r_status
  has_many :answer
  has_secure_password :validations => false

  def self.all_reports_list
  	Report.select("reports.*, r_types.r_type_txt, r_methods.r_method_txt, r_statuses.r_status_txt, projects.p_name, projects.p_season, projects.center_id, centers.center_name, projects.production_company")
  	.select("case when projects.p_season is not null then concat(projects.p_name, '. S', projects.p_season) else projects.p_name end as p_name" )
  	.select("
  	 	(	SELECT 
	            q_options.q_option_title
	        FROM
	            answers
			INNER JOIN q_options ON q_options.id = answers.q_option_id
	        WHERE
	            reports.id = answers.report_id
	                AND answers.question_id = 10
	        LIMIT 1
	    ) AS Incident_type,
			(	SELECT 
				q_options.id
			FROM
				answers
			INNER JOIN q_options ON q_options.id = answers.q_option_id
			WHERE
				reports.id = answers.report_id
					AND answers.question_id = 10
			LIMIT 1
		) AS incident_type_id,
        (	SELECT 
	            answers.a_txt
	        FROM
	            answers
	        WHERE
	            reports.id = answers.report_id
	                AND answers.question_id = 15
	        LIMIT 1
	    ) AS incident_date,
        (	SELECT 
	            answers.a_txt
	        FROM
	            answers
	        WHERE
	            reports.id = answers.report_id
	                AND answers.question_id = 13
	        LIMIT 1
	    ) AS incident_description
     ")
	.select("(	SELECT 
				q_options.q_option_title
			FROM
				answers
			INNER JOIN q_options ON q_options.question_id = answers.question_id
			WHERE
				reports.id = answers.report_id
					AND answers.question_id = 9
			LIMIT 1
		) AS position_production")
  	.select('(select count(*) from r_replies where r_replies.report_id = reports.id) as replies')
  	.joins(:r_type, :r_method, :r_status)
  	.joins("left join projects ON projects.id = reports.project_id")
  	.joins("left join centers ON centers.id = projects.center_id")
  end
end
