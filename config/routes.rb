Rails.application.routes.draw do

  scope :rails, as: 'rails', module: 'active_storage_ext' do
    resources :videos, only: [:show] do
      put :transfer, on: :member
    end
  end

  scope :rails, as: 'rails', module: 'active_storage_ext/admin' do
    resources :attachments, only: [:destroy]
    resources :blobs, only: [:index, :new, :create, :destroy]
  end

end
