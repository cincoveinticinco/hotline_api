class AddProjectToReport < ActiveRecord::Migration[6.1]
  def change
    add_reference :reports, :project, foreign_key: true, :after => :r_status_id
  end
end
