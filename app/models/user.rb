class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[google_oauth2]

  before_validation do
    self.password = Devise.friendly_token[0, 20]
  end

  def self.from_omniauth(auth)
    find_by(email: auth.info.email) do |user|
      user.email = auth.info.email
      user.image = auth.info.image # assuming the user model has an image
      # If you are using confirmable and the provider(s) you use validate emails,
      # uncomment the line below to skip the confirmation emails.
      # user.skip_confirmation!
    end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at email encrypted_password id image provider remember_created_at uid updated_at]
  end
end
