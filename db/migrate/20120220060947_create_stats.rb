class CreateStats < ActiveRecord::Migration
  def self.up
    create_table :stats do |t|
      t.column :date, :date
      t.column :todo, :float
      t.column :inprogress, :float
      t.column :done, :float
      t.column :bonus, :float
    end
  end

  def self.down
    drop_table :stats
  end
end
