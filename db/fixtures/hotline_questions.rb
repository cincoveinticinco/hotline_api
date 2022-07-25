# # 1 = "free text"
# # 2 = "Boolean"
# # 3 = "Boolean with detail"
# # 4 = "Select option"
# # 5 = "Multiple options"
# Question.seed do |s|
#   s.id = 1
#   s.r_type_id = 1
#   s.q_type_id = 4
#   s.q_title = 'Report privancy'
#   s.q_txt = ''
# end
# QOption.sedd do |s|
# s.id = 1
# s.question_id = 1
# s.q_option_title = 'Anonimous'
# s.q_option_txt = nil
# s.q_option_order = 1
# end
# QOption.sedd do |s|
# 	s.id = 2
# 	s.question_id = 1
# 	s.q_option_title = 'Identified'
# 	s.q_option_txt = nil
# 	s.q_option_order = 2
# end
# Question.seed do |s|
#   s.id = 2
#   s.r_type_id = 1
#   s.q_type_id = 2
#   s.q_title = 'Follow up'
#   s.q_txt = ''
# end
Question.seed do |s|
   s.id = 19
   s.r_type_id = 1
   s.q_type_id = 1
   s.q_title = 'Do you want to add any information to your report?'
   s.q_txt = ''
end
Question.seed do |s|
    s.id = 20
    s.r_type_id = 1
    s.q_type_id = 6
    s.q_title = 'Add files (.pdf or .jpg) Max. 5 files'
    s.q_txt = ''
 end
