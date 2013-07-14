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

  match   'home'      => 'Main#hot',            :as => 'home'
  get     'time_line' => 'Main#time_line',      :as => 'time_line'
  get     'recommend' => 'Main#recommend',      :as => 'recommend'

  get     'signup'    => 'Users#new',           :as => 'signup'
  put     'user'      => 'Users#update',        :as => 'user'
  get     'third_parties/tp_url/:type'  => 'ThirdParties#tp_url', :as => 'tp_url'
  get     'confirm'   => 'Users#confirm',       :as => 'confirm'
  get     'confirm/send' => 'Users#send_confirm', :as => 'send_confirm'
  get     'confirm/t/:token' => 'Users#get_confirm', :as => 'get_confirm'
  get     'findback' => 'Users#find_back',        :as => 'find_back'
  post    'findback/submit' => 'Users#submit_find_back',    :as => 'submit_find_back'
  get     'findback/t/:token' => 'Users#get_find_back',     :as => 'get_find_back'
  post    'findback/complete' => 'Users#complete_find_back',:as => 'complete_find_back'
  post    'blog/pagination'   => 'Main#blog',               :as => 'blog_pagination'
  post    'followers/:id'     => 'Users#follow',            :as => 'followers'
  delete  'followers/:id'     => 'Users#unfollow',          :as => 'followers'
  match   'search'  => 'Main#search', :as => 'main_search'

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
  resources :comments,  :only => [:create, :index]
  resources :tags,      :only => [:show, :create, :destroy, :index]

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
    get 'third_parties/callback/:type'  => 'ThirdParties#callback', :as => 'TP_callback'
    get 'unread_count'            => 'Notices#unread_count',  :as => 'unread_count'
    get 'third_parties/check_login/:type' => 'ThirdParties#check_login',    :as => 'TP_check_login'
    get 'third_parties/collections/:type' => 'ThirdParties#collections',    :as => 'collections'
    delete 'third_parties/:type'        => 'ThirdParties#destroy',  :as => 'TP_delete'
    get 'third_parties/upload_url/:type'  => 'ThirdParties#upload_url',     :as => 'upload_url'
    post 'domain/host/set'        => 'Settings#set_host_domain',    :as => 'set_host_domain'
    post 'notices'      => 'Notices#index'
    get 'blog/edit'     => 'Blog#edit',     :as => 'edit_blog'
    post 'blog/submit'  => 'Blog#submit',  :as => 'submit_blog'
    get 'relations'     => 'Followers#index', :as => 'relations'
    get 'relations/followers' => 'Followers#followers', as: 'relations_followers'
    get 'relations/following' => 'Followers#following', as: 'relations_following'

    resources :articles
    resources :templates, :only => [:index, :show, :create]
    resources :notices,   :only => [:index]
    namespace :admin do
      resources :users,     :only => [:index, :show, :destroy, :update]
      resources :sessions,  :only => [:destroy]
      resources :templates, :only => [:index, :destroy]
      resources :articles

      get 'search_articles'    => 'Articles#search',       :as => 'search_articles'
      get 'search_template'    => 'Templates#search',   :as => 'search_templates'
      get 'search_user'        => 'Users#search',       :as => 'search_users'
      get 'templates/default'  => 'Templates#default',  :as => 'default_templates'
      put 'templates/approve/:id'  => 'Templates#approve',  :as => 'approve_template'
      get 'templates/download/:id' => 'Templates#download', :as => 'download_template'
      match 'recommend/set/:a_id'  => 'Articles#recommend', :as => 'recommend'
      get 'recommend/articles'     => 'Articles#recommend_articles', :as => 'recommend_articles'
    end
  end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'
  root to:'Main#hot'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
