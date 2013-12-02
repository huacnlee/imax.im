Movieso::Application.routes.draw do
  # 非 API 的域名
  constraints(MainDomainMatcher) do
    match 'captcha' => EasyCaptcha::Controller, :action => :captcha, :via => :get

    devise_for :users, :path => "account", :controllers => {
        :registrations => :account,
        :sessions => :sessions
      } do
    end
    resources :movies do
      collection do
        get :top
        get :series
        get :feed
        get :feed_all
        get :search
        get :weekly
      end
      member do
        get :douban_page
        get :douban_review
        get :fetch_douban
        get :fetch_cover
        get :fetch_bg
        get :fetch_fenopy
        get :fetch_sources
        post :suggest
      end
      resources :attachs
      resources :sources
    end

    resources :attach_entries, :path => 'entries' do
      collection do
        get :search
      end
    end

    resources :users

    root :to => "home#index"
    match "/info1", :to => "home#info1"

    namespace :admin do
      root :to => 'home#index'
      resources :site_configs
      resources :movies do
        member do
          post :delete_attachs
        end
      end
      resources :users
      resources :attach_entries
      namespace :homeland, :path => "bbs" do
        resources :topics
        resources :nodes
        resources :replies
        resources :sections
      end
    end
    mount Homeland::Engine, :at => "/bbs"
  end

  namespace :api do
    resources :movies do
      collection do
        get :search
        post :multi
        get :multi
        get :top
      end
    end
  end
end
