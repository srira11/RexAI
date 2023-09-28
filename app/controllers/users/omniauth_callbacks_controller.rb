class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])

    if @user.present?
      sign_in_and_redirect @user, event: :authentication
    else
      flash[:alert] = 'Your email id is not whitelisted for the application'
      redirect_to new_user_session_path
    end
  end
end