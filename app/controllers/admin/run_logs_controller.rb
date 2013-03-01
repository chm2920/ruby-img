class Admin::RunLogsController < Admin::Backend
   
  def index
    if !params[:run_log_ids].nil?
      RunLog.destroy_all(["id in (?)", params[:run_log_ids]])
    end
    @run_logs = RunLog.paginate :page => params[:page], :per_page => 15, :order => "id desc"
  end
  
  def destroy
    @log = RunLog.find(params[:id])
    @log.destroy
    redirect_to [:admin, :run_logs]
  end
  
  def clear
    RunLog.destroy_all
    redirect_to [:admin, :run_logs]
  end
  
end
