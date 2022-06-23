class AddQuestions < ActiveRecord::Migration[6.1]
# 1 = "free text"
# 2 = "Boolean"
# 3 = "Boolean with detail"
# 4 = "Select option"
# 5 = "Multiple options"
  def change
  	[
		{
			q_type_id: 2,
			q_title: 'accept legal terms'
		},
		{
			q_type_id: 2,
			q_title: 'Accept data policy'
		},
		{
			q_type_id: 4,
			q_title: 'Report privancy',
			options: [
				'Anonimous',
				'Identified'
			]
		},
		{
			q_type_id: 2,
			q_title: 'follow up'
		},
		{
			q_type_id: 1,
			q_title: 'Email address'
		},
		{
			q_type_id: 1,
			q_title: 'phone'
		},
		{
			q_type_id: 1,
			q_title: 'first name'
		},
		{
			q_type_id: 1,
			q_title: 'last name'
		},
		{
			q_type_id: 4,
			q_title: 'Position in project',
			options: [
				'CURRENT PRODUCTION STAFF OR CREW',
				'FORMER PRODUCTION STAFF OR CREW',
				'CURRENT CAST, EXTRA OR STUNT',
				'FORMER CAST, EXTRA OR STUNT',
				'CURRENT VENDOR, CONTRACTOR OR SERVICE PROVIDER',
				'FORMER VENDOR, CONTRACTOR OR SERVICE PROVIDER',
				'OTHER'
			]
		},
		{
			q_type_id: 4,
			q_title: 'Incident type',
			options: [
				'SEXUAL HARASSMENT',
				'DISCRIMINATION',
				'VIOLENCE',
				'SAFETY / SECURITY',
				'RETALIATION',
				'DEATH',
				'MINORS',
				'HOSTILE WORK ENVIRONMENT',
				'BULLYING / INTIMIDATION',
				'ALL OTHERS'
			]
		},
		{
			q_type_id: 1,
			q_title: 'Production'
		},
		{
			q_type_id: 1,
			q_title: 'Season'
		},
		{
			q_type_id: 1,
			q_title: 'Incident detail'
		},
		{
			q_type_id: 1,
			q_title: 'People involved'
		},
		{
			q_type_id: 1,
			q_title: 'Date Incident'
		},
		{
			q_type_id: 1,
			q_title: 'Location Incident'
		},
		{
			q_type_id: 3,
			q_title: 'Incident repeated'
		},
		{
			q_type_id: 3,
			q_title: 'Incident discussed'
		}
	].each do |q|
		tq = Question.create(r_type_id: 1 ,q_type_id: q[:q_type_id] , q_title: q[:q_title] )
			q[:options].each_with_index do | e, index |
				QOption.create(:question_id => tq.id, :q_option_order => index +1,:q_option_title => e)
			end if q[:q_type_id].to_i == 4
		
	end
  end
end
