class AddLonerHashColumnToDelayedJobs < ActiveRecord::Migration
  def self.up
    add_column :delayed_jobs, :loner_hash, :string
    add_index :delayed_jobs, :loner_hash
    add_column :delayed_jobs, :loner_conflict, :string
    add_index :delayed_jobs, :loner_conflict
  end
  
  def self.down
    remove_index :delayed_jobs, :loner_hash
    remove_column :delayed_jobs, :loner_hash
    remove_index :delayed_jobs, :loner_conflict
    remove_column :delayed_jobs, :loner_conflict
  end
end