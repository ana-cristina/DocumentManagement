GoogleDrive::Application.routes.draw do
  
  # The priority is based upon order of creation:
  # first created -> highest priority.

  match "/testing" => "application#testing"
  match "/upload_file" => "application#upload_file"
  match "/update_file" => "application#update_file"
  match '/upload' => 'application#upload'
  match '/listfiles' => 'application#listfiles'
  match '/createFolder' => 'application#createFolder'
  match '/delete' => 'application#delete'
  match '/viewDocument' => 'application#viewDocument'
  match '/share' => 'application#share'
  match '/giveRights' => 'application#giveRights'
  match '/update' => 'application#update'
  match '/move' => 'application#move' 

  match '/auth/:provider/callback', :to => 'user_sessions#create'
  match '/auth/failure', :to => 'user_sessions#failure'
  #Github routes
  match '/create_repository' => 'github_action#create_repository'
  match '/authorize' => 'github_action#authorize'
  match '/get_access_token' => 'github_action#get_access_token'
  match '/list_repository' => 'github_action#list_repository'
  match '/test' => 'github_action#test'
  match '/get_data' => 'github_action#get_data'

  get '/create_repository/:id_student/:id_teacher/:repo_name.json' => 'github_action#create_repository'
  match '/create_repository/:id_student/:id_teacher/:repo_name.json' => 'github_action#create_repository'

  get '/authorize/:id_user.json' => 'github_action#authorize'
  match '/authorize/:id_user.json' => 'github_action#authorize'

  # Custom logout
  match '/logout', :to => 'user_sessions#destroy'
  root :to => 'application#index'

end
