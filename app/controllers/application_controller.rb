class ApplicationController < ActionController::Base
  before_filter :configure_permitted_parameters, if: :devise_controller?
  before_filter :rooms_user
  helper_method :background_image

  def after_sign_in_path_for(resource)
    if resource.is_a? User
        Pusher['status'].trigger('change_status', :status=>"Available",:user_id=>current_user.id)
        User.update(current_user.id, :user_status =>"Available")
        rooms_path
    else
      super
    end
  end

  def after_sign_out_path_for(resource)
    Pusher['status'].trigger('change_status', :status=>"Offline",:user_id=>current_user.id)
    User.update(current_user.id, :user_status =>"Offline")
    User.update(current_user.id, :sign_out_at => Time.now)
    if resource.is_a? User
      root_path
    else
      super
    end
  end

  def background_image()
    Dir.chdir(Rails.root+"public/background")
    target = Dir.new("#{Dir.pwd}")
    target.entries.sort![rand(2..target.entries.size-1)]
  end

  private

  def rooms_user
    @room_list=Room.where("id in (?)",RoomsUser.where(:user_id=>current_user.id).pluck(:room_id)).order(id: :asc)
  end


def configure_permitted_parameters
    devise_parameter_sanitizer.for(:sign_up) << :login
    devise_parameter_sanitizer.for(:sign_in) { |u| u.permit(:email, :password, :remember_me) }
    devise_parameter_sanitizer.for(:sign_up) { |u| u.permit({ roles: [] },:firstname,:lastname,:avatar, :email, :password, :password_confirmation, :login) }
  end


  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  #protect_from_forgery with: :exception
end
