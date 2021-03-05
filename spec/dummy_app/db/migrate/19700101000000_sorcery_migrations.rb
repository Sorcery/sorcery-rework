class SorceryMigrations < ActiveRecord::Migration[6.0]
  def change
    create_table :admins do |t|
      t.string :email, null: false
      t.string :crypted_password
      t.string :salt

      # Brute Force Protection
      t.integer  :failed_logins_count, default: 0
      t.datetime :lock_expires_at,     default: nil
      t.string   :unlock_token,        default: nil

      t.timestamps
    end

    create_table :users do |t|
      t.string :username, null: false
      t.string :email
      t.string :crypted_password
      t.string :salt

      # Brute Force Protection
      # t.integer  :pineapple_count, default: 0
      # t.datetime :pineapple_at,    default: nil
      # t.string   :pineapple_token, default: nil

      t.timestamps
    end
  end
end
