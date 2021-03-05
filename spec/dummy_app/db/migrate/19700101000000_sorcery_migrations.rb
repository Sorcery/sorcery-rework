class SorceryMigrations < ActiveRecord::Migration[6.0]
  def change
    create_table :admins do |t|
      t.string :email, null: false
      t.string :crypted_password
      t.string :salt

      t.timestamps
    end

    create_table :users do |t|
      t.string :username, null: false
      t.string :email
      t.string :crypted_password
      t.string :salt

      t.timestamps
    end
  end
end
