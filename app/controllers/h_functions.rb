def set_error_message_and_generate_json(status, message)
    error_hash = {}
    error_hash["status"] = status
    error_hash["message"] = message
    respond_to do |format|
      format.json { render :json => error_hash.to_json }
    end
end

def set_success_and_generate_json
    error_hash = {}
    error_hash["status"] = SUCCES
    respond_to do |format|
      format.json { render :json => error_hash.to_json }
    end
end

#TODO: to be tasted 
#TODO: de adaugat fctia in documentatie
def grant_rights_to_users(user_who_requested, users_to_receive_right, document_id_gd, document_path, right)
  document_id = get_database_id_from_document_id(document_id_gd)
  is_folder = is_folder_from_database(document_id_gd)

  users_to_receive_right.each do |user|
  permission = Permission.where(:document_id => document_id, :user_id => user)
  if permission.first == nil
    if(is_folder== true)
      right=='upload'? insert_into_permissions_table(user, document_id, document_path,false, false, false, false, true, true, true): nil
    end
    right=='update'?  insert_into_permissions_table(user, document_id, document_path, true, false, false, false, true, false, false): nil
    right=='delete'? insert_into_permissions_table(user, document_id, document_path, false, true, false, false, true, false, false): nil
    right=='move'?  insert_into_permissions_table(user, document_id, document_path, false, false, true, false, true, false, false): nil
    right=='share'?  insert_into_permissions_table(user, document_id, document_path, false, false, false, true, true, false, false): nil
    right=='create_folder'?  insert_into_permissions_table(user, document_id, document_path, false, false, false, false, true, false, true): nil
    else
    if(is_folder == true)
      right=='upload'? (permission.first.p_upload = true ) : nil
      right=='upload'? (permission.first.p_create_folder = true ) : nil
    end      
      right=='update'?  (permission.first.p_update = true) : nil
        right=='delete'? (permission.first.p_delete = true) : nil
        right=='move'? (permission.first.p_move = true) : nil
        right=='share'? (permission.first.p_share = true) : nil
        right=='create_folder'? (permission.first.p_create_folder = true) : nil
				permission.first.save      
			end
		end
#TODO: trebuie testat
#=begin
		if (is_folder == true) 
			children_files = Document.where(:parent_dir => document_id)
			children_files.each do |child|
				grant_rights_to_users(user_who_requested,users_to_receive_right, child.document_id, child.document_path,right)
			end
		end
#=end	
	end 

 def update_database_entry_in_permissions(old_doc_id, new_doc_id)
    permission = Array.new
    permission = Permission.where(:document_id => old_doc_id)
    permission.each do |perm|
      perm.document_id = new_doc_id
      perm.save
    end
  end
  
  def update_database_entry_in_documents(old_doc_id_gd, new_doc_id_gd, old_doc_title, new_doc_title)
    document = Document.where(:document_id  => old_doc_id_gd)
    document.each do |doc|
      doc.document_id = new_doc_id_gd
      doc.document_name = new_doc_title
			doc.save
    end
  end

	def update_database_entry(old_doc_id_gd,new_doc_id_gd, old_doc_title, new_doc_title)
   	update_database_entry_in_documents(old_doc_id_gd, new_doc_id_gd, old_doc_title, new_doc_title)
  end

  def inherit_rights_from_parent(document_id, parent_id, is_folder, user_id)
      permission = Array.new
      permission = Permission.where(:document_id => parent_id)
      document = Document.where(:id => document_id)
			parent_name = Document.where(:id => parent_id)
			#raise('mesaj')
      permission.each do |perm|
				if(perm.user_id != user_id) 
		      child_permission = Permission.new(:document_id => document_id)
		      child_permission.document_path = perm.document_path + parent_name[0].document_name + '/'
		      child_permission.user_id = perm.user_id
					child_permission.p_update = perm.p_update #cel care a uploadat fisierul are toate permisiunile activate pentru el
		      child_permission.p_delete = perm.p_delete
		      child_permission.p_move = perm.p_move
		      child_permission.p_share = perm.p_share
					child_permission.p_view = perm.p_view
					if(is_folder == true ) 
						child_permission.p_upload = perm.p_upload #cel care a uploadat fisierul are toate permisiunile activate pentru el
	 	      	child_permission.p_create_folder = perm.p_create_folder
					else
						child_permission.p_upload = false
	 	      	child_permission.p_create_folder = false				
					end
		      child_permission.save
				end
    	end  
  end  

#TODO: de adaugat o coloana : is admin si de verificat daca id_user e admin
  def user_is_admin(id_user)
=begin   
   user = User.where(:uid => id_user)
   if user[0] != nil and user[0].is_admin == true
     return true
   end
   return false		
   #if ( id_user == '777' ) 
    # return true
   #end  
   #return false
=end
    return true 
  end
  
  def split_all(path)
    head, tail = File.split(path)
    return [tail] if head == '.' || tail == '/'
    return [head, tail] if head == '/'
    return split_all(head) + [tail]
  end
  
  def get_lPath(location_path, id_module)
    if(location_path == nil || location_path.length()==0)
      return lpath = '/' + id_module + '/';
    else
      return lpath = '/' + id_module +'/'+location_path+'/';
    end
  end
  
  def get_lPath_permissions(location_path, id_module)
    if(location_path == nil || location_path.length()==0)
      return lpath = '/'
    else
      #'/1/ddd/dosar'
      poz = location_path.rindex('/')
      if(poz!=nil)
        location_path = location_path.slice(0,poz)
      end
      if poz == nil
         return lpath = '/' + id_module +'/'
      
      end 
      return lpath = '/' + id_module + '/' + location_path +'/'
    end
  end
  
  def get_lPath_for_init_folders(id_module)
    return lpath = '/'
  end
  
  def retrieve_file_id(path_to_file, file_name)
    path_to_file = split_all(path_to_file)
    cfolder =   SESSION.root_collection()

    if(path_to_file != nil || path_to_file.length>0)
      folders = path_to_file.split(File::SEPARATOR)
      
      folders.each do |var|
        p var
        cfolder = cfolder.subcollection_by_title(var)
        if cfolder == nil
          a = {}
          a["status"] = ERROR
          a["message"] = LOCATIONNOTAVAILABLE
          respond_to do |format|
            format.json { render :json => a.to_json }
          end
          return
        end
      end
    end
    file = cfolder.file_by_title(file_name)
    if file == nil
          a = {}
          a["status"] = ERROR
          a["message"] = FILENOTFOUND
          return a
    end
          a = {}
          a["status"] = SUCCES
          a["message"] = file.resource_id
          return a
  end

  def get_database_id_from_document_id(file_id) 
		document = Document.where(:document_id =>file_id)
		if(document[0] !=nil) 
			return document[0].id
		end		
		return nil	
	end

	def is_folder_from_database(file_id) 
		document = Document.where(:document_id =>file_id)
		if(document[0] !=nil) 
			return document[0].folder_or_file
		end		
		return nil	
	end
  def user_has_permission_to_view(user_id, file_path, file_id)
			id_doc = get_database_id_from_document_id(file_id)
      permission = Permission.where(:user_id => user_id, :document_path => file_path, :document_id => id_doc)  
      if permission == nil || permission.length == 0 
        return false
      end
      if  permission[0].p_view == false
        return false
      end  
      return true
    end

    def user_has_permission_to_delete(user_id, file_path, file_id)
      id_doc = get_database_id_from_document_id(file_id)
      permission = Permission.where(:user_id => user_id, :document_path => file_path, :document_id => id_doc)   
      if permission == nil || permission.length == 0 
        return false
      end
      if  permission[0].p_delete == false
        return false
      end  
      return true
    end
  
    def user_has_permission_to_update(user_id, file_path, file_id)
     id_doc = get_database_id_from_document_id(file_id)
      permission = Permission.where(:user_id => user_id, :document_path => file_path, :document_id => id_doc)  
      if permission == nil || permission.length == 0 
        return false
      end
      if  permission[0].p_update== false
        return false
      end  
      return true 
    end

    def user_has_permission_to_share(user_id, file_path, file_id)
			id_doc = get_database_id_from_document_id(file_id)
      permission = Permission.where(:user_id => user_id, :document_path => file_path, :document_id => id_doc)    
      if permission == nil || permission.length == 0 
        return false
      end
      if  permission[0].p_share == false
        return false
      end  
      return true
    end

    def user_has_permission_to_upload(user_id, file_path, file_id)
#raise('mesaj')
      id_doc = get_database_id_from_document_id(file_id)
		
      permission = Permission.where(:user_id => user_id, :document_path => file_path, :document_id => id_doc)    
						#raise('mesaj')
      if permission == nil || permission.length == 0 
        return false
      end
      if  permission[0].p_upload == false
        return false
      end  
      return true
    end

     def user_has_permission_to_create_folder(user_id, file_path, file_id)
     id_doc = get_database_id_from_document_id(file_id)
      permission = Permission.where(:user_id => user_id, :document_path => file_path, :document_id => id_doc)   
      if permission == nil || permission.length == 0 
        return false
      end
      if  permission[0].p_create_folder == false
        return false
      end  
      return true
    end
  
    def insert_into_permissions_table(id_user, file_id, file_path, update, delete, move, share, view, upload, create_folder)
		#	raise('mesaj')
			if user_is_admin(id_user) == true
				return true 
			end
      permission = Permission.new(:document_id => file_id, :user_id => id_user, :document_path => file_path)
      if permission.new_record? == true
        permission.p_update = update #cel care a uploadat fisierul are toate permisiunile activate pentru el
        permission.p_delete = delete
        permission.p_move = move
        permission.p_share = share
        permission.p_view = view
        permission.p_upload = upload
        permission.p_create_folder = create_folder
        status = permission.save
        return status
      end
   return false
    end

  def insert_into_documents_table(id_user, file_id, file_title, is_folder, file_path, parent_dir)
    document = Document.new(:document_id => file_id)
    if document.new_record? == true
      document.document_path = file_path
      document.folder_or_file = is_folder
      document.document_name = file_title
      document.document_uploader = id_user
      document.parent_dir = parent_dir
      status = document.save 
      return document.id
    end
    return false
  end
  
  def store_into_database(id_user, file_id, file_title, is_folder, file_path, parent_dir_gd)
		parent_dir = nil
	#	raise('mesaj')
		if ( parent_dir_gd != nil)
			parent_dir = get_database_id_from_document_id(parent_dir_gd)		
		end    

		insert_document_id = insert_into_documents_table(id_user, file_id, file_title, is_folder, file_path, parent_dir)
	
    if is_folder == true  
      insert_permission = insert_into_permissions_table(id_user, insert_document_id, file_path, false, true, true, true, true, true, true)
    else
      insert_permission = insert_into_permissions_table(id_user, insert_document_id, file_path, true, true, true, true, true, false, false)
    end
    
    if insert_document_id.present? && insert_permission == true
      return true
    else
      return false
    end
  end
  
  def delete_document_from_documents_and_permissions(file_path, file_id)
    document = Document.where(:document_path => file_path, :document_id=> file_id)
    document.destroy_all
    if document.length == 0 
      return true
    else
      return false
    end
  end
  
  
  def add_index_to_database(module_id,user_id)
    x = SESSION.collection_by_title(module_id)
    lpath = get_lPath_for_init_folders(module_id)
  #  store_into_database(user_id, x.resource_id, x.title,true, lpath)
  end  
  
  def add_permissions_to_admin(user_id)
    add_index_to_database(1,user_id)
    add_index_to_database(2,user_id)
    add_index_to_database(3,user_id)
    add_index_to_database(4,user_id)
    add_index_to_database(5,user_id)
    add_index_to_database(6,user_id)
    add_index_to_database(7,user_id)
    add_index_to_database(8,user_id)
    add_index_to_database(9,user_id)
    add_index_to_database(10,user_id)
    add_index_to_database(11,user_id)
    add_index_to_database(12,user_id)
  end
