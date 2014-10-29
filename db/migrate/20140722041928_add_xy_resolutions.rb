class AddXyResolutions < ActiveRecord::Migration
  def change
    add_column :photos, :x_resolution, :integer
    add_column :photos, :y_resolution, :integer
  end
end
