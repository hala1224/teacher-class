class CreateCategories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
       t.string :content
       t.integer :teacher_id
    end
  end
end
