class Categories < ActiveRecord::Migration
  def change
    create_table :categories do |t|
       t.string :username
       t.string :email
       t.string :password_digest
    end
  end
end
