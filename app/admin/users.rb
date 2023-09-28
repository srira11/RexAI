ActiveAdmin.register User do
  permit_params :email, :password, :password_confirmation, :image

  index do
    selectable_column
    id_column
    column :email
    column :image
    actions
  end

  filter :email

  form do |f|
    f.inputs do
      f.input :email
      f.input :password
      f.input :password_confirmation
      f.input :image
    end
    f.actions
  end

end
