class RoomsController < ApplicationController
  before_filter :authenticate_user!

  def new
    @new_room = Room.new
  end

  def index
    @rooms_preload=RoomsUser.preload(:user)
  end

  def create
    @room = Room.create(room_params.merge(:user_id=>current_user.id)) #FIXME refactoring (create)
    RoomsUser.create(:user_id => current_user.id, :room_id => @room.id) #FIXME refactoring (create)
    if params[:express]
      Pusher["private-#{params[:user_id]}"].trigger_async('user_add_to_room', {:rooms_id=>@room.id,:rooms_name=>@room.name})
      RoomsUser.create(:user_id => params[:user_id], :room_id => @room.id)
      render :json=>@room.id,:root=>false
    else
      @rooms_preload=RoomsUser.preload(:user)#FIXME refactoring
      @room_list=Room.includes(:rooms_users).where('rooms_users.user_id'=>current_user.id).preload(:user).order(id: :asc)
      respond_to do |format|
        format.html { redirect_to rooms_path}
        format.js {}
        format.json { render json: @room_list, status: :created}
      end
    end
  end

  def show #FIXME refactoring (tut vse ploho)
    @message = Message.new
    if Room.includes(:rooms_users).where('rooms_users.user_id'=>current_user.id,'rooms.id'=>params[:id].to_i).exists?
      gon.room_id = params[:id]
      @messages = Message.where(:room_id=>params[:id]).preload(:user).order(created_at: :asc).last(10)
    else
      gon.room_id = 0
    end
    @room_users =User.includes(:rooms_users).where('rooms_users.room_id'=>params[:id])
    gon.rooms_users = @room_users.pluck(:login)
    gon.user_login = current_user.login
    gon.user_id = current_user.id
  end

  def delete_room
    room=Room.where("user_id = ? AND id = ?",current_user.id,params[:id]).first
    room.destroy
    Pusher['status'].trigger('delete_room', :room_id=>params[:id])
  end

  def load_previous_10_msg
    if Room.includes(:rooms_users).where('rooms_users.user_id'=>current_user.id,'rooms.id'=>params[:room_id].to_i).exists?
      previous_messages = Message.offset(params[:offset_records].to_i).where(:room_id=>params[:room_id]).preload(:user).order(created_at: :desc).last(10);
      render :json => previous_messages
    end
  end

  private
  def room_params
    params.require(:room).permit( :name, :topic)
  end

end
