require 'pathname'
require 'h_functions.rb'
require 'tempfile'
class ApplicationController < ActionController::Base
  protect_from_forgery
#TODO: de decomentat cand punem pe heroku 
 # before_filter :login_required

def get_id_of_current_folder_from_path(id_module, location_of_folder)
    current_folder = SESSION.collection_by_title(id_module)

    if(location_of_folder!=nil && location_of_folder.length>0)
      folders = split_all(location_of_folder)
      folders.each do |var|
        current_folder = current_folder.subcollection_by_title(var)
        if current_folder == nil
          set_error_message_and_generate_json(ERROR, LOCATIONNOTAVAILABLE)
          return
        end
      end
    end

    parent_directory_id = current_folder.resource_id
    return parent_directory_id
end

def get_parent_id_from_database(parent_id_from_gdrive)
  document = Document.where(:document_id => parent_id_from_gdrive)
  if document.first != nil
    return document.first.id
  end
 # set_error_message_and_generate_json(ERROR, DOCUMENTNOTINDATABASE)
  return nil
end
def upload_file
end
def upload2
    #http://localhost:3000/upload.json?id_module=adina&id_user=777&path_to_file=/home/adina/aaa.txt
    #http://localhost:3000/upload.json?id_module=ana&id_user=777&path_to_file=/home/ana/ana.txt

    id_module = params[:id_module]
    id_user = params[:id_user]
    path_to_file = params[:path_to_file]
    location_path = params[:location_path]
    lpath = get_lPath_permissions(location_path,id_module)
    # raise "me"
    parent_directory_id = get_id_of_current_folder_from_path(id_module, location_path)
    cfolder = SESSION.collection_by_title(id_module)
   
    if(location_path !=nil && location_path.length>0)
      folders = split_all(location_path)
      folders.each do |var|
        cfolder = cfolder.subcollection_by_title(var)
        if cfolder == nil
          set_error_message_and_generate_json(ERROR, LOCATIONNOTAVAILABLE)
          return
        end
      end
    end
    #raise('mesaj')
    if user_is_admin(id_user) == false and user_has_permission_to_upload(id_user, lpath, cfolder.resource_id) == false
      set_error_message_and_generate_json(ERROR, NOTPERMITTED)
      return
    end
    
       #verificam daca exista unul cu acelasi nume
      title = File.basename(path_to_file)
      if cfolder.file_by_title(title) != nil
        set_error_message_and_generate_json(ERROR, DUPLICATEFILE)
        return
      end
      
      file = SESSION.upload_from_file(path_to_file)
      
       if file == nil
        set_error_message_and_generate_json(ERROR, FILENOTFOUND)
        return
      end
      
      cfolder.add(file)
      SESSION.root_collection.remove(file)
      fileLink = file.human_url
      lpath = get_lPath(location_path,id_module)
      
      
      
     ok = store_into_database(id_user, file.resource_id, title, false, lpath, parent_directory_id)
      #raise('mesaj')
      if ok == false
        set_error_message_and_generate_json(FALSE, DATABASEERROR)
        file.delete()
        return
      end 

      db_parent_id = get_parent_id_from_database(parent_directory_id)      
      database_file_id = Document.where(:document_id => file.resource_id)
      if db_parent_id != nil
        #document_id, parent_id, is_folder, user_id
        inherit_rights_from_parent(database_file_id.first.id, db_parent_id, false, id_user) 
      end
      set_success_and_generate_json
    end

def upload
    id_module = params[:id_module]
    id_user = params[:id_user]
#    path_to_file = params[:path_to_file]
     title = params[:title]


     content_hash = JSON.parse( params[:path_to_file].to_s)
   
    #content = content_hash["tempfile"][0] 
    File.open(Rails.root.join('public','cacat.txt'), "w+") {  |file| file.write content_hash.to_s
								#|file| content_hash["tempfile"].each do |str|
								#		file.puts str
								#		end  }
}
    path_to_file  = Rails.root.join('public','cacat.txt').to_s
    location_path = params[:location_path]

    lpath = get_lPath_permissions(location_path,id_module)
    if( id_user == nil)
	set_error_message_and_generate_json(ERROR, USERNULL) 
	return
    end
    parent_directory_id = get_id_of_current_folder_from_path(id_module, location_path)
    
    cfolder = SESSION.collection_by_title(id_module)
    if( cfolder == nil) 
      set_error_message_and_generate_json(ERROR, LOCATIONOFMODULENOTAVAILABLE) 
      return
    end
    if(location_path !=nil && location_path.length>0)
      folders = split_all(location_path)
      folders.each do |var|
        cfolder = cfolder.subcollection_by_title(var)
        if cfolder == nil
          set_error_message_and_generate_json(ERROR, LOCATIONNOTAVAILABLE)
          return
        end
      end
    end
   #raise('mesaj')
    if user_is_admin(id_user) == false and user_has_permission_to_upload(id_user, lpath, cfolder.resource_id) == false
      set_error_message_and_generate_json(ERROR, NOTPERMITTED)
      return
    end
    
       #verificam daca exista unul cu acelasi nume
      #title = File.basename(path_to_file)
     
      if cfolder.file_by_title(title) != nil
        set_error_message_and_generate_json(ERROR, DUPLICATEFILE)
        return
      end
      
      file = SESSION.upload_from_file(path_to_file)
      file.rename(title)
      params = {}
      params[:reload] = true
      file.title(params)
     
      if file == nil
        set_error_message_and_generate_json(ERROR, FILENOTFOUND)
        return
      end
      
      cfolder.add(file)
      SESSION.root_collection.remove(file)
      fileLink = file.human_url
      lpath = get_lPath(location_path,id_module)
				
      ok = store_into_database(id_user, file.resource_id, title, false, lpath, parent_directory_id)
			
      if ok == false
	set_error_message_and_generate_json(FALSE, DATABASEERROR)
        file.delete()
        return
      end 

      db_parent_id = get_parent_id_from_database(parent_directory_id)      
      database_file_id = Document.where(:document_id => file.resource_id)
      if db_parent_id != nil
	#document_id, parent_id, is_folder, user_id
        inherit_rights_from_parent(database_file_id.first.id, db_parent_id, false, id_user) 
      end
      set_success_and_generate_json
    end
     
  def listfiles
    #http://localhost:3000/listfiles.json?id_module=1&id_user=5
    id_module = params[:id_module]
    id_user = params[:id_user]
    location_path = params[:location_path]
    lpath = get_lPath(location_path,id_module)
   
    if( id_user == nil)
      set_error_message_and_generate_json(ERROR, USERNULL) 
      return
    end

    cfolder =   SESSION.collection_by_title(id_module)
    if( cfolder == nil) 
      set_error_message_and_generate_json(ERROR, LOCATIONOFMODULENOTAVAILABLE) 
      return
    end

    if(location_path!=nil && location_path.length>0)
        folders = split_all(location_path)
 
       folders.each do |var|
        cfolder = cfolder.subcollection_by_title(var)
        if cfolder == nil
	  set_error_message_and_generate_json(ERROR, LOCATIONNOTAVAILABLE)
        return
        end
      end
    end
    
    listF={}
    cfolder.files.map {
      |i| 
      if user_is_admin(id_user) == true or user_has_permission_to_view(id_user,lpath,i.resource_id)==true  
          p lpath     
          listF[i.title] = i.resource_type 
      end
            
    }
   if(	listF.length == 0 )
    set_error_message_and_generate_json(ERROR, NOFILES)
    return
   end
   # cfolder.subcollections.map{|i| listF[i.title] = i.human_url}
    a = {}
    a["status"] = SUCCES
    a["filelist"] = listF
    respond_to do |format|
      format.json { render :json => a.to_json }
    end
  end
  
  def createFolder
    #http://localhost:3000/createFolder.json?id_module=adina&id_user=777&name=ddd
    id_module = params[:id_module]
    id_user = params[:id_user]
    name = params[:name]
    location_path = params[:location_path]
		
    if( id_user == nil)
     set_error_message_and_generate_json(ERROR, USERNULL) 
     return
    end

    if(name == nil || name.length <=0)
     set_error_message_and_generate_json(ERROR, NAMENULL)
     return
    end
    
    cfolder = SESSION.collection_by_title(id_module)

    if( cfolder == nil) 
      set_error_message_and_generate_json(ERROR, LOCATIONOFMODULENOTAVAILABLE) 
    end
    if(location_path!=nil && location_path.length>0)
      folders = split_all(location_path)
      folders.each do |var|
        cfolder = cfolder.subcollection_by_title(var)
        if cfolder == nil
          set_error_message_and_generate_json(ERROR, LOCATIONNOTAVAILABLE) 
          return
        end
      end
    end
    sub = cfolder.subcollection_by_title(name)
    if sub != nil 
      set_error_message_and_generate_json(ERROR, DUPLICATEFILE)  
      return
    end

    lpath = get_lPath_permissions(location_path,id_module)
#		raise('mesaj')		
    if user_is_admin(id_user) == false and user_has_permission_to_create_folder(id_user,lpath,cfolder.resource_id) == false
      set_error_message_and_generate_json(ERROR, NOTPERMITTED)
      return
    end

    lpath = get_lPath(location_path,id_module)
    sub = cfolder.create_subcollection(name)

    if(location_path == nil )
      store_into_database(id_user, sub.resource_id, sub.title, true, lpath, nil)
    else
      store_into_database(id_user, sub.resource_id, sub.title, true, lpath, cfolder.resource_id)
    end  

   db_parent_id = get_parent_id_from_database(cfolder.resource_id)      
   database_file_id = Document.where(:document_id => sub.resource_id)
   if db_parent_id != nil
     inherit_rights_from_parent(database_file_id.first.id, db_parent_id, true, id_user) 
   end

   set_success_and_generate_json
 end

 def delete
    #localhost:3000/delete.json?id_module=2&id_user=5&name=dddaaa    
    id_module = params[:id_module]
    id_user = params[:id_user]
    name = params[:name]
    location_path = params[:location_path]
    
    if( id_user == nil)
      set_error_message_and_generate_json(ERROR, USERNULL) 
      return
    end
    lpath = get_lPath(location_path,id_module)
    if(name == nil || name.length <=0)
      set_error_message_and_generate_json(ERROR, NAMENULL)
      return
    end
    
    cfolder = SESSION.collection_by_title(id_module)
    if( cfolder == nil) 
      set_error_message_and_generate_json(ERROR, LOCATIONOFMODULENOTAVAILABLE) 
      return
    end

    if(location_path!=nil && location_path.length>0)
      folders = split_all(location_path)
      folders.each do |var|
        cfolder = cfolder.subcollection_by_title(var)
        if cfolder == nil
          set_error_message_and_generate_json(ERROR, LOCATIONNOTAVAILABLE)
          return
        end
      end
    end

    file = cfolder.file_by_title(name)
    if(file == nil)
      set_error_message_and_generate_json(ERROR, FILENOTFOUND)
      return
    end

    if  user_is_admin(id_user) == false and user_has_permission_to_delete(id_user,lpath,file.resource_id)==false
      set_error_message_and_generate_json(ERROR, NOTPERMITTED)
      return
    end
   
    delete_document_from_documents_and_permissions(lpath,file.resource_id)
    
    file.delete()
    
    set_success_and_generate_json
end
  
 def viewDocument
    #http://localhost:3000/viewDocument.json?id_module=2&id_user=5&name=aaa.txt&location_path=ddd
    id_module = params[:id_module]
    id_user = params[:id_user]
    location_path = params[:location_path]
    name = params[:name]
    lpath = get_lPath(location_path,id_module)
    
    if( id_user == nil)
     set_error_message_and_generate_json(ERROR, USERNULL) 
     return
    end
		
    if(name == nil || name.length <=0)
      set_error_message_and_generate_json(ERROR, NAMENULL)
      return
    end
    cfolder =   SESSION.collection_by_title(id_module)
    if( cfolder == nil) 
      set_error_message_and_generate_json(ERROR, LOCATIONOFMODULENOTAVAILABLE)
      return 
    end

    if(location_path!=nil && location_path.length>0)
        folders = split_all(location_path)

      folders.each do |var|
        cfolder = cfolder.subcollection_by_title(var)
        if cfolder == nil
	  set_error_message_and_generate_json(ERROR, LOCATIONNOTAVAILABLE)
          return
        end
      end
    end
     
    file = cfolder.subcollection_by_title(name) 
    if file != nil
      set_error_message_and_generate_json(ERROR, ISFOLDER)
      return
    else
    file = cfolder.file_by_title(name)
    if user_is_admin(id_user) == false and user_has_permission_to_view(id_user,lpath,file.resource_id) == false
      set_error_message_and_generate_json(ERROR, NOTPERMITTED)
      return
    end
    if file == nil 
      set_error_message_and_generate_json(ERROR, FILENOTFOUND)
      return
    end
    
    path ="./tmp/drivedocs/"
    ttle = "i"+id_module+SecureRandom.hex(7) + file.title
    path.concat(ttle)
    
    file.download_to_file(path)

    send_file Rails.root.join("tmp","drivedocs",ttle)
    end
end
  
 def update_file
 end

 def update
    #localhost:3000/update.json?path_to_file=/home/adina/aaa.txt&id_module=1&id_user=5&old_file_name=aaa.txt
    id_module = params[:id_module]
    id_user = params[:id_user]
    name = params[:old_file_name]
    #path_to_file = params[:path_to_file]
    path_to_file = params[:path_to_file].tempfile.path
	
    if(name == nil || name.length <=0)
      set_error_message_and_generate_json(ERROR, NAMENULL)
      return
    end
    
		location_path = params[:path_to_old_file]
		if( id_user == nil)
			set_error_message_and_generate_json(ERROR, USERNULL) 
			return
		end
    lpath = get_lPath(location_path,id_module)
    cfolder =   SESSION.collection_by_title(id_module)
		if( cfolder == nil) 
			   set_error_message_and_generate_json(ERROR, LOCATIONOFMODULENOTAVAILABLE) 
				return
		end
    #parsam location_path ca sa ajungem in folder :)
    if(location_path!=nil && location_path.length>0)
        folders = split_all(location_path)
      	folders.each do |var|
        cfolder = cfolder.subcollection_by_title(var)
        if cfolder == nil
          set_error_message_and_generate_json(ERROR, LOCATIONNOTAVAILABLE)
          return
        end
      end
    end
    
    file = cfolder.file_by_title(name)
    if(file == nil )
      set_error_message_and_generate_json(ERROR, FILENOTFOUND)
      return
    end
    
    if user_is_admin(id_user) == false and user_has_permission_to_update(id_user,lpath,file.resource_id)==false
      set_error_message_and_generate_json(ERROR, NOTPERMITTED)
      return
    end
    
    fileupdated = SESSION.upload_from_file(path_to_file)
 		fileupdated.rename(name)
      params = {}
      params[:reload] = true
      fileupdated.title(params)
    cfolder.add(fileupdated)
    SESSION.root_collection.remove(fileupdated)
    newname = File.basename(path_to_file)
    update_database_entry(file.resource_id,fileupdated.resource_id, name, newname)    
    file.delete
               
    fileLink = fileupdated.human_url
    
    set_success_and_generate_json
end

  def move
    #http://localhost:3000/move.json?id_module=1&id_user=5&name=aaa.txt&location_path=ddd
    #http://localhost:3000/move.json?id_module=2&id_user=5&name=aaa.txt&location_path=ddd
    id_module = params[:id_module]
    id_user = params[:id_user]
    name = params[:name]
    path_to_file = params[:path_to_file] #from
    location_path = params[:location_path]#where
    lpathnew = get_lPath_permissions(location_path,id_module)
    lpathold = get_lPath(path_to_file,id_module)
    
		if( id_user == nil)
			set_error_message_and_generate_json(ERROR, USERNULL) 
			return
		end
    if(name == nil || name.length <=0)
      set_error_message_and_generate_json(ERROR, NAMENULL)
      return
    end
    
    cfolder =   SESSION.collection_by_title(id_module)
		if( cfolder == nil) 
			   set_error_message_and_generate_json(ERROR, LOCATIONOFMODULENOTAVAILABLE) 
				return
		end

    if(location_path!=nil && location_path.length>0)
        folders = split_all(location_path)
      folders.each do |var|
        cfolder = cfolder.subcollection_by_title(var)
        if cfolder == nil
          set_error_message_and_generate_json(ERROR, LOCATIONNOTAVAILABLE)
          return
        end
      end
    end
    folderwhere = cfolder
    cfolder =   SESSION.collection_by_title(id_module)
    
    if(path_to_file!=nil && path_to_file.length>0)
        folders = split_all(path_to_file)
        folders.each do |var|
        cfolder = cfolder.subcollection_by_title(var)
        if cfolder == nil
	  set_error_message_and_generate_json(ERROR, LOCATIONNOTAVAILABLE)
          return
        end
      end
    end
    folderfrom = cfolder
    
    file = folderfrom.file_by_title(name)
        if file == nil
	  set_error_message_and_generate_json(ERROR, FILENOTFOUND)
          return
        end
       
    if user_is_admin(id_user) == false and (user_has_permission_to_delete(id_user,lpathold,file.resource_id)==false || 
     user_has_permission_to_upload(id_user,lpathnew,folderwhere.resource_id)==false)
      set_error_message_and_generate_json(ERROR, NOTPERMITTED)
      return
    end  
    

    path = "./tmp/drivedocs"
		ttle = "i"+id_module+SecureRandom.hex(7) + name
    path.concat(ttle)

    file.download_to_file(path)
		
    lpathnew = get_lPath(location_path,id_module)
    lpathold = get_lPath(path_to_file,id_module)
     
    delete_document_from_documents_and_permissions(lpathold,file.resource_id)
    
    file.delete()
    fileupdated = SESSION.upload_from_file(path)
 		fileupdated.rename(name)
      params = {}
      params[:reload] = true
      file.title(params)
    folderwhere.add(fileupdated)
    #id_user, file_id, file_title, is_folder, file_path
    
    store_into_database(id_user, fileupdated.resource_id, name, false, lpathnew,folderwhere.resource_id)

    SESSION.root_collection.remove(fileupdated)

    fileLink = fileupdated.human_url

    set_success_and_generate_json
  end
#TODO : folder, apoi folder in folder, apoi giveRights sau Share pt primul folder. Al doilea nu primeste 

  def giveRights
		#http://localhost:3000/giveRights.json?id_module=adina&id_user=777&name=ddd&Users=5,1,2&right=upload
		id_module = params[:id_module]
    user_who_requested = params[:id_user]
    location_path = params[:location_path]
    users_array_f = params[:Users]
    name = params[:name]
		right = params[:right]
		if( id_user == nil)
			set_error_message_and_generate_json(ERROR, USERNULL) 
			return
		end
		if( right == nil ) 
			set_error_message_and_generate_json(ERROR,NULLRIGHT)
			return		
		end
		users_to_receive_right = Array.new
    users_array_f.split(",").map { |s| users_to_receive_right.push(s) }
    if( users_to_receive_right.length == 0)
			set_error_message_and_generate_json(ERROR, NOUSERSSELECTED) 
			return
		end
		lpath = get_lPath(location_path,id_module)

		cfolder = SESSION.collection_by_title(id_module)
    #parsam location_path ca sa ajungem in folder :)
    if(location_path!=nil && location_path.length>0)
        folders = split_all(location_path)
      folders.each do |var|
        cfolder = cfolder.subcollection_by_title(var)
        if cfolder == nil
          set_error_message_and_generate_json(ERROR, LOCATIONNOTAVAILABLE)
          return
        end
      end
    end
		
    file = cfolder.file_by_title(name)
		if( file == nil)
			set_error_message_and_generate_json(ERROR, FILENOTFOUND)
      return
		end
    file_id = file.resource_id

		#raise('mesaj')
		if( user_is_admin(user_who_requested) == true ) 
			grant_rights_to_users(user_who_requested, users_to_receive_right, file_id, lpath, right)
		else 
			set_error_message_and_generate_json(ERROR, NOTPERMITTED)	
			return	
		end
    set_success_and_generate_json
	end
  
	def share
    #http://localhost:3000/share.json?id_module=1&id_user=777&name=main.cpp&Users=5,1,2,3,4
    #http://localhost:3000/share.json?id_module=adina&id_user=777&name=aaa.txt&Users=5,1,2
    id_module = params[:id_module]
    id_user = params[:id_user]
    path_to_file = params[:path_to_file]
    users_array_f = params[:Users]
    name = params[:name]
    users_array = Array.new
    users_array_f.split(",").map { |s| users_array.push(s) }
    
    lpath = get_lPath(path_to_file,id_module)
    file_info = retrieve_file_id(lpath,name)
    
    if(file_info['status'] == ERROR)
      set_error_message_and_generate_json(ERROR, FILENOTFOUND)
      return
    end
    file_id = file_info['message']
    if user_is_admin(id_user) == true or  user_has_permission_to_share(id_user, lpath, file_id) == true
      operation_success = true    
      users_array.each do |user|
				doc_id = get_database_id_from_document_id(file_id);
        permission = Permission.where(:user_id => user, :document_path => lpath, :document_id => doc_id)
        current_status = true
			#	raise('mesaj')
        if permission.first == nil
          current_status = insert_into_permissions_table(user, doc_id, lpath, false, false, false, false, true, false, false)
        else
          current_status = permission.first.p_view = true 
					permission.first.save
        end
      end
    end
     set_success_and_generate_json
     return
  end
 
 
  def index
  end

  ################################################partea celor de la autentificare
  def login_required
    if !current_user
      respond_to do |format|
       format.html  {
          redirect_to '/auth/autentificare'
        }
        format.json {
          render :json => { 'error' => 'You are not logged in. Access denied' }.to_json
        }
      end
    end
  end

  def current_user
    return nil unless session[:user_id]
    @current_user ||= User.find_by_uid(session[:user_id]['uid'])
  end

end
