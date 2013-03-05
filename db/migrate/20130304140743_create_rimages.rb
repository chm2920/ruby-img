class CreateRimages < ActiveRecord::Migration
  def change
    create_table :rimages do |t|
      t.string :path
      t.string :extName
      t.integer :scale
      t.integer :width
      t.integer :height
      t.text :weights
      t.string :total
      t.integer :state

      t.timestamps
    end
  end
end
