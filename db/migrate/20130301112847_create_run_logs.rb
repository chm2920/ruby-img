class CreateRunLogs < ActiveRecord::Migration
  def self.up
    create_table :run_logs do |t|
      t.string :log_path
      t.string :log_method
      t.string :log_params
      t.string :log_exception
      t.string :log_remote_ip
      
      t.datetime :created_at
    end
  end

  def self.down
    drop_table :run_logs
  end
end
