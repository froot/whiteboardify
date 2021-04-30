Rails.application.routes.draw do
  post '/images', to: 'images#create'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
