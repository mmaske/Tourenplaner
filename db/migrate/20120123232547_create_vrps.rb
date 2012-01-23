class CreateVrps < ActiveRecord::Migration
  def self.up
    create_table :vrps do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :vrps
  end
end
