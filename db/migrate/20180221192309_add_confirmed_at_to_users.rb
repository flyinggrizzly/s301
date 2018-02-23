class AddConfirmedAtToUsers < ActiveRecord::Migration[5.1]
  def up
    add_confirmation_columns

    # Ensure any existing users get grandfathered in with confirmation
    User.all.each do |u|
      u.email_confirmed_at = Time.now
      u.save
    end
  end

  def down
    revert { add_confirmation_columns }
  end

  private

  def add_confirmation_columns
    add_column :users, :email_confirmation_token, :string, null: false, default: ''
    add_column :users, :email_confirmed_at, :datetime
  end
end
