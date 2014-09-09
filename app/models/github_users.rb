class GithubUsers < ActiveRecord::Base
  attr_accessible :git_id, :token, :user_id, :username
end
