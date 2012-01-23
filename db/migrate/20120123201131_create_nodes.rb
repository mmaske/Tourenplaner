class CreateNodes < ActiveRecord::Migration
  def self.up
    create_table :nodes do |t|
      t.float :latitude
      t.float :longitude
      t.boolean :gmaps
      t.string :street
      t.string :city
      t.string :country
      t.float :demand

      t.timestamps
    end
  end

  def self.down
    drop_table :nodes
  end
end
