class Admin::RimagesController < Admin::Backend
   
  def index
    if !params[:rimage_ids].nil?
      Rimage.destroy_all(["id in (?)", params[:rimage_ids]])
    end
    @rimages = Rimage.paginate :page => params[:page], :per_page => 15, :order => "id desc"
  end
  
  def destroy
    @rimage = Rimage.find(params[:id])
    @rimage.destroy
    redirect_to [:admin, :rimages]
  end
  
  def clear
    Rimage.destroy_all
    redirect_to [:admin, :rimages]
  end
  
end
