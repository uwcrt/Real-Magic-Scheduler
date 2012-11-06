class RemoveOldFieldsFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :email
    remove_column :users, :encrypted_password
    remove_column :users, :salt
  end

  def self.down
  end
end
