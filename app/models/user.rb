class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :rememberable, :validatable, :omniauthable, omniauth_providers: %i[google_oauth2]
  def self.from_omniauth(auth)
    user = find_by(email: auth.info.email)
    user.update(image: auth.info.image) unless user.image.present?
    user
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at email encrypted_password id image remember_created_at updated_at]
  end
end
