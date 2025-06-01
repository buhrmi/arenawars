class SessionsController < ApplicationController
  def new
    if params[:provider]
      # Just render the ERB template that automatically makes a POST request to /auth/:provider
      render layout: false
    end
  end

  def create
    if request.env["omniauth.auth"].present?
      create_from_omniauth
    else
      create_from_handle_or_email
    end
  end

  def create_from_handle_or_email
    user = User.authenticate_by(email: params[:email], password: params[:password])
    if user
      session[:user_id] = user.id
      flash.now[:notice] = "You have been logged in."
    else
      flash[:error] = "Invalid email or password."
      redirect_to new_session_path
    end
  end

  def create_from_omniauth
    identity = Identity.from_omniauth!(request.env["omniauth.auth"], current_user)
    if current_user && current_user != identity.user
      flash[:error] = "This account is already connected to another user."
    else
      session[:user_id] = identity.user.id
      flash[:notice] = "You have been logged in."
    end
    render layout: false
  end

  def destroy
    session[:user_id] = nil
    flash[:just_logged_out] = true
    flash.now[:notice] = "You have been logged out."
  end
end
