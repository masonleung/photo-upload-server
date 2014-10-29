class CreatePhotosTable < ActiveRecord::Migration
  def up
    create_table :photos do |t|
      t.string :name
      t.integer :x_size
      t.integer :y_size
      t.integer :quality
      t.timestamps
    end
  end

  def down
    drop_table :photos
  end
end
