# coding: utf-8
class AccountController < ApplicationController
  
  layout false
  
  def login
  end
  
  def login_rst
    if !params[:name].blank? && !params[:password].blank?
      adminname = params[:name]
      password = Digest::MD5.hexdigest(params[:password])
      @admin = Admin.find_by_adminname(adminname)
      if @admin.nil?
        @err_msg = "用户名密码错误。"
      else
        if @admin.password == password
          session[:admin] = @admin.adminname
          session[:admin_id] = @admin.id
          redirect_to :action => 'main'
          return
        else
          @err_msg = "用户名密码错误!"
        end
      end            
    else
      @err_msg = "用户名密码不能为空。"
    end
    render :action => "login"
  end
  
  def main
    if session[:admin_id].nil?
      redirect_to "/"
    end
  end
  
  def desktop
    render :layout => 'backend'
  end
  
  def logout
    session[:admin_id] = nil
    redirect_to :action => 'login'
  end
  
end