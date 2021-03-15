class SorceryMigrations < ActiveRecord::Migration[6.0]
  # TODO: Should this be broken into multiple migrations separated by table?
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
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

      # Activity Logging
      t.datetime :last_login_at,              default: nil
      t.datetime :last_logout_at,             default: nil
      t.datetime :last_activity_at,           default: nil
      t.string   :last_login_from_ip_address, default: nil

      # Brute Force Protection
      t.integer  :pineapple_count, default: 0
      t.datetime :pineapple_at,    default: nil
      t.string   :pineapple_token, default: nil

      t.timestamps
    end
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
