require 'open-uri'
require 'json'
require "net/http"

class GithubActionController < ApplicationController
# before_filter :login_required
 
  def authorize
    #/authorize?id_user=12456789
    user_id = params[:id_user]
    address = GITHUB.authorize_url redirect_uri: "#{REDIRECT_GIT}/get_access_token.json?id_user=#{user_id}", scope: ['repo', 'user']
    redirect_to address
  end
  
  def get_access_token
    access_code = params[:code] 
    user_id = params[:id_user]
    tokenn = GITHUB.get_token( access_code )
    token = tokenn.token
    github_user = Github.new(:oauth_token => token)
    username = github_user.users.get.login
    a = {}
    insert_git_user = insert_into_github_table(user_id,username,token)
  
    if insert_git_user == true 
      a["status"] = SUCCESS
      a["user_id"]= user_id
      a["username"] = username
      a["token"] = token     
    else
      a["status"] = ERROR
      a["message"] = DATABASEERROR
    end

   uri = URI.parse("http://fmi-autentificare.herokuapp.com/get_github/#{user_id}/#{SUCCESS}/#{username}/#{token}")
   parameters = { "oauth_token" => @current_user.token }
   response = Net::HTTP.post_form(uri,parameters)
#  redirect_to "#{AUTH}/get_github/#{user_id}/success/#{username}/#{token}"
#	http://fmi-autentificare.herokuapp.com/get_github/:user_id/:status/:username/:token 
#    a["response"] = response

    respond_to do |format|
        format.json { render :json => a.to_json }
    end
  end
  def test
  raise "mesaj"
  end

  def insert_into_github_table(user,username,token)     
    ok = GithubUsers.where(:user_id =>user, :username => username)
    if ok.first == nil 
      github_user = GithubUsers.new(:user_id => user)
      if github_user.new_record? == true
        github_user.token = token
        github_user.username = username
        status = github_user.save 
        return status
      end
    else
      return false
    end  
    return false
  end

  def get_data
   @result = JSON.parse(open("http://fmi-autentificare.herokuapp.com/git/#{@current_user.uid}.json?oauth_token=#{@current_user.token}").read)
   a = {}
   a ["info"] = @result
   respond_to do |format|
        format.json { render :json => a.to_json }
    end
  end
  def get_from_auth_github_user_info(user_id)
    @result = JSON.parse(open("http://fmi-autentificare.herokuapp.com/git/#{user_id}.json").read)
    a= {}
    if @result[0]["student"] == nil 
      if @result[0]["teacher"] != nil
        a["status"] = SUCCESS
        a["username"] = @result[0]["teacher"]["git_user"]
        a["token"] = @result[0]["teacher"]["git_token"]
      else
        a["status"] = ERROR
      end  
    else
      a["status"] = SUCCESS
      a["username"] = @result[0]["student"]["git_user"]
      a["token"] = @result[0]["student"]["git_token"]

    end
    return a
  end
  def get_from_auth_github_user_info_local(user_id)    
    user = GithubUsers.where(:user_id => user_id)
    a = {} 
    if user.first == nil
      a["status"] = ERROR     
    else
      a["status"] = SUCCESS
      a["username"] = user[0].username
      a["token"] = user[0].token
    end
    return a
  end

  def create_team(user1,user2,name)
    team = GITHUB_ADMIN.orgs.teams.create 'fmi-source-code-app',
        "name" => name,
        "permission" => "push"
    GITHUB_ADMIN.orgs.teams.add_member team.id, user1
    GITHUB_ADMIN.orgs.teams.add_member team.id, user2
    return team.id
  end

  def create_repository
#/create_repository.json?id_student=123&id_teacher=122&repo_name=testname
    user1_id = params[:id_student]
    user2_id = params[:id_teacher]
    repo_name = params[:repo_name]
    name = repo_name.concat(SecureRandom.hex(5))
    if ( user1_id.present? && user2_id.present? && name.present?)
      user1_info = get_from_auth_github_user_info(user1_id) 
      user2_info = get_from_auth_github_user_info(user2_id)
      if ( user1_info["status"] == SUCCESS && user2_info["status"] == SUCCESS)
        team = create_team(user1_info["username"],user2_info["username"], name)
        new_repo = GITHUB_ADMIN.repos.create :name => name,
            :homepage => "https://github.com",
            :private => false,
            :has_issues => true,
            :has_wiki => true,
            :has_downloads => true,
            :org => "fmi-source-code-app",
            :team_id  => team,
            :auto_init => true   
        a = {}
        a["status"] = SUCCESS
        a["link"]= new_repo.git_url
      else
        a={}
        a["status"] = ERROR
        a["message"] = DATABASEERROR
      end
    else
      a = {}
      a["status"] = ERROR
      a["message"]= PARAMETERNULL
    end
    respond_to do |format|
      format.json { render :json => a.to_json }
    end
  end
 
  def list_repository
    #TODO parsat json
    user_id = params[:id_user]
    user_info = get_from_auth_github_user_info(user_id) 
    github_user = Github.new(:oauth_token => user_info["token"])
    repos = github_user.repos.list   
    a = {}
    a["status"] = SUCCESS
    a["content"]= repos.inspect.to_s
    respond_to do |format|
      format.json { render :json => a.to_json }
    end
  end
  def index
  end
end
