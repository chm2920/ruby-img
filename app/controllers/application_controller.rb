class ApplicationController < ActionController::Base
  protect_from_forgery
  
  def self.rescue_errors
    rescue_from Exception,                            :with => :render_error
    rescue_from RuntimeError,                         :with => :render_error
    rescue_from ActiveRecord::RecordNotFound,         :with => :render_not_found
    rescue_from ActionController::RoutingError,       :with => :render_not_found
    rescue_from ActionController::UnknownController,  :with => :render_not_found
    rescue_from ActionController::UnknownAction,      :with => :render_not_found
  end
  rescue_errors
  
  def render_not_found(exception=nil)
    record_error(params[:path])
    render :template => "errors/404", :status => 404, :layout => "application"
  end
  
  def render_error(exception)
    record_error(exception)
    render :template => "errors/500", :status => 500, :layout => "application"
  end
  
  def record_error(e)
    RunLog.log_info(params, request, e)
  end
  
  
  def store_location
    session[:return_to] = request.request_uri
  end
  
  def redirect_back
    redirect_to(session[:return_to] || "/")
    session[:return_to] = nil
  end

end
