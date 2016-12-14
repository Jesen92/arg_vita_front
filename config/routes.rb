Rails.application.routes.draw do


  get 'accounts/my_account'

  get 'accounts/purchases'

  get 'purchases/create'

  get 'auctions/index'

  get 'auctions/show'

  get 'complements/index'

  get 'complements/show'

  get 'complements/new'

  get 'complements/create'

  get 'complements/edit'

  get 'complements/update'

  get 'complements/destroy'

  get 'repromaterijal/index'

  get 'repromaterijal/show'

  get 'trgovina/index'

  get 'trgovina/show'

  get 'past_purchases/index'

  get 'past_purchases/show'

  get 'past_purchases/create'

  get 'past_purchases/edit'

  get 'past_purchases/update'

  get 'past_purchases/destroy'

  get 'carts_articles/index'

  get 'carts_articles/show'

  get 'carts_articles/new'

  get 'carts_articles/create'

  get 'carts_articles/edit'

  get 'carts_articles/update'

  get 'carts_articles/destroy'

  get 'carts_articles/plus_no_user'

  get 'carts_articles/min_no_user'

  get 'shopping_carts/index'

  get 'shopping_carts/show'

  get 'shopping_carts/new'

  get 'shopping_carts/create'

  get 'shopping_carts/edit'

  get 'shopping_carts/update'

  get 'shopping_carts/destroy'

  get 'orders/index'

  get 'orders/show'

  get 'orders/new'

  get 'orders/create'

  get 'orders/edit'

  get 'orders/update'

  get 'orders/destroy'

  get 'shopping_carts/index'

  get 'shopping_carts/show'

  get 'clients/show'

  get 'articles/index'

  get 'articles/index_subcategories'

  get 'articles/show'

  get 'categories/index'

  get 'categories/show'

  get 'home/index'

  get 'trgovina/categories' => "trgovina#categories", :as => 'categories'

  get 'trgovina/index_of' => "trgovina#index_of", :as => 'index_of'

  get 'repromaterijal/categories' => "repromaterijal#categories", :as => 'categories_repro'

  get 'repromaterijal/index_of' => "repromaterijal#index_of", :as => 'index_of_repro'

  get 'articles/search_art' => "articles#search_art", :as => 'search_art'

  get 'auctions/complement_show' => "auctions#complement_show", :as => 'complement_show'

  get 'home/general' => "home#general", :as => 'general'

  get 'home/download_pdf' => "home#download_pdf", :as => 'download_pdf'

  get 'home/privacy'

  resources :home do
    get :general, on: :collection
    get :download_pdf, on: :collection
  end
  resources :purchases
  resources :auctions do
    put :new_bid, on: :collection
    put :complement_show, on: :collection
  end
  resources :articles do
    put :search_art, on: :collection
  end
  resources :complements
  resources :categories
  resources :clients
  resources :subcategories
  resources :ssubcategories
  resources :shopping_carts do
    put :destroy_single, on: :collection
    put :destroy_complement, on: :collection
  end
  resources :carts_articles do
    put :single, on: :collection
    post :create_single, on: :collection
    put :plus_no_user, on: :collection
    put :min_no_user, on: :collection
    put :create_complement, on: :collection

  end
  resources :trgovina do
    get :categories, on: :collection
    put :index_of, on: :collection
  end
  resources :repromaterijal do
    get :categories, on: :collection
    put :index_of, on: :collection
  end

  devise_for :users, controllers: { registrations: "users/registrations"}
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
   root 'home#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
