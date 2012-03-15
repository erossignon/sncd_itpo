class AddStatColumnForBugs < ActiveRecord::Migration
  def self.up
    add_column :stats, :open_bug, :float
    add_column :stats, :in_progress_bug, :float
    add_column :stats, :closed_bug, :float
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

