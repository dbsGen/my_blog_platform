BlogSystem::Application.routes.draw do
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)
  get     'login'     => 'Sessions#new',        :as => 'login'
  delete  'logout'    => 'Sessions#destroy',    :as => 'logout'

  get     'home'      => 'Main#home_page',      :as => 'home'
  get     'popular'   => 'Main#popular_page',   :as => 'popular'
  get     'recommend' => 'Main#recommend_page', :as => 'recommend'
  get     'last'      => 'Main#last_page',      :as => 'last'

  get     'signup'    => 'Users#new',           :as => 'signup'
  put     'user'      => 'Users#update',        :as => 'user'
  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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
  resources :users,     :only => [:create]
  resources :sessions,  :only => [:create]
  resources :articles,  :only => [:show]

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
  namespace :account do
    get 'settings'                => 'Settings#show',         :as => 'settings'
    get 'third_parties'           => 'ThirdParties#show',     :as => 'third_parties'
    get 'search_articles'         => 'Articles#search',       :as => 'search_articles'
    get 'third_parties/callback/:from'  => 'ThirdParties#callback', :as => 'TP_callback'
    delete 'third_parties/:type'        => 'ThirdParties#destroy',  :as => 'TP_delete'
    resources :articles
    resources :templates, :only => [:index, :show]
    namespace :admin do
      resources :users,     :only => [:index, :show, :destroy, :update]
      resources :sessions,  :only => [:destroy]
      resources :templates, :only => [:index, :destroy]
      resources :articles

      get 'search_articles'    => 'Articles#search',       :as => 'search_articles'
      get 'search_template'    => 'Templates#search',   :as => 'search_templates'
      get 'search_user'        => 'Users#search',       :as => 'search_users'
      get 'templates/default'  => 'Templates#default',  :as => 'default_templates'
    end
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'
  root to:'Main#home_page'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
