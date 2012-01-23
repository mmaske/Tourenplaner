class CreateVehicles < ActiveRecord::Migration
  def self.up
    create_table :vehicles do |t|
      t.string :ID
      t.string :Type
      t.float :Capacity

      t.timestamps
    end
  end

  def self.down
    drop_table :vehicles
  end
end
