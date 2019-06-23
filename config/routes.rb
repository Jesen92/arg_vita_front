Rails.application.routes.draw do


  get 'trgovina_category/index'

  get 'trgovina_category/show'

  get 'favorites/index'

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

  put 'carts_articles/create'

  get 'carts_articles/edit'

  get 'carts_articles/update'

  get 'carts_articles/destroy'

  get 'carts_articles/plus_no_user'

  get 'carts_articles/min_no_user'

  get 'shopping_carts/index'

  get 'shopping_carts/show'

  get 'shopping_carts/new'

  put 'shopping_carts/create'

  get 'shopping_carts/edit'

  get 'shopping_carts/update'

  put 'shopping_carts/destroy'

  post 'shopping_carts/check_coupon'

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

  get 'home/payment_methods' => "home#payment_methods", :as => 'payment_methods'

  get 'home/download_pdf' => "home#download_pdf", :as => 'download_pdf'

  get 'home/privacy'

  get 'home/contact_page' => "home#contact_page", :as => 'contact_page'

  get 'home/about_us_page' => "home#about_us_page", :as => 'about_us_page'

  get 'accounts/:id' => "accounts#show", :as => 'show_purchase'

  put 'shopping_carts/destroy_item' => "shopping_carts#destroy_item", :as => 'destroy_item'
  put 'shopping_carts/destroy_single_item' => "shopping_carts#destroy_single_item", :as => 'destroy_single_item'

  resources :home do
    get :general, on: :collection
    get :download_pdf, on: :collection
    post :contact_us, on: :collection
    get :delivery_payment_info, on: :collection
    get :loyalty_program, on: :collection
  end
  resources :purchases do
    get :purchase_success, on: :collection
    post :purchase_success_credit_card, on: :collection
    get :purchase_success_credit_card, on: :collection
  end
  #resources :auctions do
  #  put :new_bid, on: :collection
  #  put :complement_show, on: :collection
  #end
  resources :articles do
    member do
      put "like" => "articles#downvote"
      put "dislike" => "articles#upvote"
    end
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
    put :destroy_item, on: :collection
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

  namespace :ajax do
    resources :carts_articles do
      member do
        put "create" => "carts_articles#create", defaults: { format: 'js' }
        put "create_single" => "carts_articles#create_single", defaults: { format: 'js' }
        put "destroy_amount" => "carts_articles#destroy", defaults: { format: 'js' }
        put "destroy_item" => "carts_articles#destroy_item", defaults: { format: 'js' }
        put "destroy_single_item" => "carts_articles#destroy_single_item", defaults: { format: 'js' }
        put "destroy_single_amount" => "carts_articles#destroy_single", defaults: { format: 'js' }
      end
    end
    resources :shopping_carts do
      member do
        put "create" => "shopping_carts#create", defaults: { format: 'js' }
        put "create_single" => "shopping_carts#create_single", defaults: { format: 'js' }
        put "destroy_amount" => "shopping_carts#destroy", defaults: { format: 'js' }
        put "destroy_item" => "shopping_carts#destroy_item", defaults: { format: 'js' }
        put "destroy_single_item" => "shopping_carts#destroy_single_item", defaults: { format: 'js' }
        put "destroy_single_amount" => "shopping_carts#destroy_single", defaults: { format: 'js' }
      end
    end
  end

  devise_for :users, controllers: { registrations: "users/registrations", sessions: "users/sessions"}
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
