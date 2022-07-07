class UserHasProject < ApplicationRecord
  belongs_to :user
  belongs_to :project

  def self.getUserProject(project_id)
    UserHasProject.select('user_has_projects.*,users.email')
    .joins(:user)
    .where('project_id=?',project_id)
  end
end
