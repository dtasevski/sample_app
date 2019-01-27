class PasswordResetsController < ApplicationController

  before_action :get_user, only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Please check your email"
      redirect_to root_url
    else
      flash.now[:danger] = "Email not found"
      render 'new'
    end
  end

  def edit
  end

  def update
  if password_blank?
      flash.now[:danger] = "Fields cannot be blank"
    elsif @user.update_attributes(user_params)
      log_in @user
      flash[:success] = "Password updated"
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

    def get_user
      @user = User.find_by(email: params[:email])
    end

  #confirms a valid user
    def valid_user
      unless @user && @user.authenticated?(:reset, params[:id]) && @user.activated?
        redirect_to root_url
      end
    end

    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset token has expired"
        redirect_to new_pasword_reset_url
      end
    end

    def password_blank?
      params[:user][:password].blank?
    end

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end
end
