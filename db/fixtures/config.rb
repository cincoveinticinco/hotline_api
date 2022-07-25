# REPORT TYPES
RType.seed do |s|
  s.id = 1
  s.r_type_txt = "production_hotline"
end
#REPORT METHODS
RMethod.seed do |s|
  s.id = 1
  s.r_method_txt = "Online"
end
RMethod.seed do |s|
  s.id = 2
  s.r_method_txt = "Phone"
end
RMethod.seed do |s|
  s.id = 3
  s.r_method_txt = "WhatsApp"
end
#REPORT STATUS
RStatus.seed do |s|
  s.id = 1
  s.r_status_txt = "Started"
end
RStatus.seed do |s|
  s.id = 2
  s.r_status_txt = "New"
end
RStatus.seed do |s|
  s.id = 3
  s.r_status_txt = "Under review"
end
RStatus.seed do |s|
  s.id = 4
  s.r_status_txt = "More information needed"
end
RStatus.seed do |s|
  s.id = 5
  s.r_status_txt = "To review"
end
RStatus.seed do |s|
  s.id = 6
  s.r_status_txt = "Closed"
end
#REPORT TYPES
QType.seed do |s|
  s.id = 1
  s.q_type_txt = "Free text"
end
QType.seed do |s|
  s.id = 2
  s.q_type_txt = "Boolean"
end
QType.seed do |s|
  s.id = 3
  s.q_type_txt = "Boolean with detail"
end
QType.seed do |s|
  s.id = 4
  s.q_type_txt = "Select option"
end
QType.seed do |s|
  s.id = 5
  s.q_type_txt = "Multiple options"
end
QType.seed do |s|
  s.id = 6
  s.q_type_txt = "Multiple File"
end
# centers
Center.seed do |s|
  s.id = 1
  s.center_name = "Brasil"
end
Center.seed do |s|
  s.id = 2
  s.center_name = "Mexico"
end
Center.seed do |s|
  s.id = 3
  s.center_name = "Rola"
end
UserType.seed do |s|
  s.id = 1
  s.user_type_name = "General user"
end
UserType.seed do |s|
  s.id = 2
  s.user_type_name = "Project user"
end
Language.seed do |s|
  s.id = 1
  s.l_name = "English"
end
Language.seed do |s|
  s.id = 2
  s.l_name = "Spanish"
end
Language.seed do |s|
  s.id = 3
  s.l_name = "Portugues"
end