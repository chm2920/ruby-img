RubyImg::Application.routes.draw do
  
  match "sample" => "start#sample"
  match "about" => "start#about"
  match "upload" => "start#upload"
  match "crop" => "start#crop"
  match "generate_m" => "start#generate_m"
  
    
  match "admin" => "account#login"
  get "account/main"
  get "account/desktop"
  match "admin_login_rst" => "account#login_rst"
  match "admin_logout" => "account#logout"
  
  
  namespace :admin do
    
    get "rimages/index"
    post "rimages/index"
    get "rimages/clear"
    resources :rimages
    
    get "run_logs/index"
    post "run_logs/index"
    get "run_logs/clear"
    resources :run_logs
    
    get "admins/index"
    post "admins/index"
    resources :admins
  end

  get 'kindeditor/images_list'

  post 'kindeditor/upload'

  root :to => "start#index"
  
  match "*path" => "application#render_not_found"
  
end
