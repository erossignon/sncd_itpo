class AddStatColumn < ActiveRecord::Migration
  def self.up
    add_column :stats, :inprogress_done, :float

    add_column :stats, :todo_feature_count, :float
    add_column :stats, :inprogress_feature_count, :float
    add_column :stats, :inprogress_done_feature_count, :float
    add_column :stats, :done_feature_count, :float
    add_column :stats, :bonus_feature_count, :float
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end

