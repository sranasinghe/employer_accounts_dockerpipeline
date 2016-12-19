Rails.application.routes.draw do
  use_doorkeeper
  resources :sessions

  resource :reset_password, path: '/reset-password', only: [:update] do
    get :verify_token, path: 'verify-token'
    get :get_question, path: 'get-question'
    post :answer_question, path: 'answer-question'
  end

  resource :reset_email, path: '/reset-email', only: [:update] do
    post :find_member, path: 'find-member'
  end

  mount GrapeSwaggerRails::Engine => '/docs'
  mount EmployerAccountsApp => '/'
end
