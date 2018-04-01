class UsersController < Clearance::UsersController
  skip_before_action :redirect_signed_in_users
  before_action :require_login

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = "User #{@user.email} created"
      redirect_to root_url
    else
      render 'new'
    end
  end

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
  end

  def delete
    @user = User.find(params[:id])
  end

  def destroy
    @user = User.find(params[:id])
    @user.destroy
    flash[:success] = "User #{@user.email} has been deleted"
    redirect_to users_path
  end
end
