class ExtendUser < ActiveRecord::Migration
  def self.up
    add_column :users, :multipass_remote_uid, :string
  end

  def self.down
    remove_column :users, :multipass_remote_uid
  end
end