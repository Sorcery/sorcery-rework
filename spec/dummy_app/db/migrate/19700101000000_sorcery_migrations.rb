class SorceryMigrations < ActiveRecord::Migration[6.0]
  # TODO: Should this be broken into multiple migrations separated by table?
  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def change
    create_table :admins do |t|
      t.string :email, null: false
      t.string :password_digest

      # Brute Force Protection
      t.integer  :failed_logins_count, default: 0
      t.datetime :lock_expires_at,     default: nil
      t.string   :unlock_token,        default: nil

      # Remember Me
      t.string   :remember_me_token,            default: nil
      t.datetime :remember_me_token_expires_at, default: nil

      t.timestamps
    end

    create_table :users do |t|
      t.string :username, null: false
      t.string :email
      t.string :password_digest

      # Activity Logging
      t.datetime :last_login_at,              default: nil
      t.datetime :last_logout_at,             default: nil
      t.datetime :last_activity_at,           default: nil
      t.string   :last_login_from_ip_address, default: nil

      # Brute Force Protection
      t.integer  :pineapple_count, default: 0
      t.datetime :pineapple_at,    default: nil
      t.string   :pineapple_token, default: nil

      # Remember Me
      t.string   :remember_me_token,            default: nil
      t.datetime :remember_me_token_expires_at, default: nil

      t.timestamps
    end

    create_table :user_sessions do |t|
      t.belongs_to :user, null: false, foreign_key: true

      t.timestamps
    end

    create_table :admin_sessions do |t|
      t.belongs_to :admin, null: false, foreign_key: true, unique: true

      t.timestamps
    end

    # add_index :admin_sessions, :admin_id, unique: true
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength
end
