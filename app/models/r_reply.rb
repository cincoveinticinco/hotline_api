class RReply < ApplicationRecord
  belongs_to :report
  belongs_to :user, optional: true
  def self.reportReplies()
  	RReply.select("r_replies.id, r_replies.report_id,r_replies.reply_txt, r_replies.user_id, r_replies.updated_at as date")
  	.select("if(users.id is null, 'Reporter', 'Hotline team') as user_name" ) 
  	.joins("left join users ON users.id = r_replies.user_id")
  	.order("r_replies.updated_at DESC")
  end
end
