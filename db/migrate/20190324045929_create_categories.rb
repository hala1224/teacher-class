class CreateCategories < ActiveRecord::Migration[5.2]
  def change
    create_table :categories do |t|
      t.string :content
      t.integer :teacher_id
    end
  end
end
