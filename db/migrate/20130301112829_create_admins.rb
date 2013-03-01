class CreateAdmins < ActiveRecord::Migration
  def self.up
    create_table :admins do |t|
      t.column :adminname, :string
      t.column :password, :string
      t.timestamps
    end
    
    Admin.create(:adminname => "admin", :password => "21232f297a57a5a743894a0e4a801fc3")
  end

  def self.down
    drop_table :admins
  end
end
