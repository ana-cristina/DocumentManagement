class Permission < ActiveRecord::Base
  attr_accessible :document_id, :document_path, :p_create_folder, :p_delete, :p_move, :p_share, :p_update, :p_upload, :p_view, :user_id
end
