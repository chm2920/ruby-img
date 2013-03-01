class Admin::AdminsController < Admin::Backend
  
  def index
    @admins = Admin.all
  end

  def new
    @admin = Admin.new
  end

  def edit
    @admin = Admin.find(params[:id])
  end
  
  def create
    @admin = Admin.new(params[:admin])
    if @admin.save
      redirect_to [:admin, :admins]
    else
      render :action => "new"
    end
  end

  def update
    @admin = Admin.find(params[:id])
    if !params[:admin][:password].blank?
      @admin.adminname = params[:admin][:adminname]
      @admin.password = Digest::MD5.hexdigest(params[:admin][:password])
      @admin.save!
    end
    redirect_to [:admin, :admins]
  end

  def destroy
    @admin = Admin.find(params[:id])
    @admin.destroy
    redirect_to [:admin, :admins]
  end
  
end
