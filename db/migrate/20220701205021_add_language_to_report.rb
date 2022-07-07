class AddLanguageToReport < ActiveRecord::Migration[6.1]
  def change
  	Language.create(l_name: 'English')
    add_reference :reports, :language, null: false, :default => 1, foreign_key: true, :after => :id
  end
end
