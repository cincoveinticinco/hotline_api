class AddLocationToProject < ActiveRecord::Migration[6.1]
  def change
    add_reference :projects, :location, null: false, foreign_key: true, :after => :center_id
  end
end
