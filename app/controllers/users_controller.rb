class UsersController < Clearance::UsersController
  def create
    @user = user_from_params
    @user.email_confirmation_token = Clearance::Token.new

    if @user.save
      UserMailer.registration_confirmation(@user).deliver
      redirect_to root_url
    else
      render template: 'users/new'
    end
  end
end
