class CreateRStatuses < ActiveRecord::Migration[6.1]
  def change
    create_table :r_statuses do |t|
      t.string :r_status_txt

      t.timestamps
    end
  end
end
