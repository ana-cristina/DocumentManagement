class User < ActiveRecord::Base
  attr_accessible :first_name, :is_admin, :last_name, :uid, :token
end
