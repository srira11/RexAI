class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :validatable

  def self.ransackable_attributes(auth_object = nil)
    %w[created_at email encrypted_password id updated_at]
  end
end
