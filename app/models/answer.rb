class Answer < ApplicationRecord
  belongs_to :question
  belongs_to :report

  def self.reportAnswers()
  	Answer.select(" 
		answers.id,
		answers.question_id,
		questions.q_type_id,
		q_types.q_type_txt,
		questions.q_title,
		questions.q_txt,
		answers.updated_at,
		answers.a_txt,
		answers.a_yes_or_no,
		answers.q_option_id,
		q_options.q_option_title,
		(case 
			when questions.q_type_id = 1 then answers.a_txt
			when reports.language_id = 1 and questions.q_type_id = 2 and answers.a_yes_or_no = true then 'Yes' 
			when reports.language_id = 2 and questions.q_type_id = 2 and answers.a_yes_or_no = true then 'Si'
			when reports.language_id = 3 and questions.q_type_id = 2 and answers.a_yes_or_no = true then 'Sim' 
			when reports.language_id != 3 and questions.q_type_id in (2,3)  and answers.a_yes_or_no = false then 'No'
			when reports.language_id = 3 and questions.q_type_id in (2,3)  and answers.a_yes_or_no = false then 'Não'
			when reports.language_id = 1 and questions.q_type_id = 3 and answers.a_yes_or_no = true then concat( 'Yes, ',  answers.a_txt) 
			when reports.language_id = 2 and questions.q_type_id = 3 and answers.a_yes_or_no = true then concat( 'Si, ',  answers.a_txt)
			when reports.language_id = 3 and questions.q_type_id = 3 and answers.a_yes_or_no = true then concat( 'Sim, ',  answers.a_txt) 
			when questions.q_type_id = 4  then q_options.q_option_title
		end) as answer_text
	")
	.joins(:question)
	.joins(:report)
	.joins("INNER JOIN q_types ON questions.q_type_id = q_types.id")
	.joins("LEFT JOIN q_options ON answers.q_option_id = q_options.id")
	.order('answers.question_id')
  end
end
