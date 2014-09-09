class Document < ActiveRecord::Base
  attr_accessible :document_id, :document_name, :document_path, :document_uploader, :folder_or_file, :parent_dir
end
