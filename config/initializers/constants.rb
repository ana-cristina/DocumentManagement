SESSION = GoogleDrive.login("document.source.management@gmail.com", "proiectip")
ERROR = 'ERROR'
USERNULL = 'User id cannot be NULL'
SUCCES = 'Succes'
DATABASEERROR ='Database error'
NOTPERMITTED = ' Permission not granted / not enough rights'
LOCATIONNOTAVAILABLE = 'Location not available'
LOCATIONOFMODULENOTAVAILABLE = 'ID Module is not correct' 
DUPLICATEFILE = 'Duplicate file, please try to update'
FILENOTFOUND = 'File not found'
NAMENULL = 'Name is NULL '
ISFOLDER = 'Is Folder'
DOCUMENTNOTINDATABASE = 'the document was not found in the database. try erasing and reuploading'
NOFILES = 'No files'
NOUSERSSELECTED = 'No users'
NULLRIGHT = 'Right cannot be null'
#Github constants
#LOCAL
#GITHUB = Github.new :client_id => 'f8b9f04f7fce71fcc970', :client_secret => '48f63af6473f5799838b5a733ecdd70ee1403eb4' 
#REDIRECT_GIT = 'http://localhost:3000'
#HEROKU
GITHUB = Github.new :client_id => 'ca35c1a95eebd1608d89', :client_secret => '2a6d26a3729482e538098be7a9fbc6d807425549' 
REDIRECT_GIT = 'http://doc-source.herokuapp.com'
GITHUB_ADMIN = Github.new :oauth_token => '39d82176f7ce0c3f190775c1fbf812ea37e4cee7'
PARAMETERNULL = 'Parameter is null'
SUCCESS = 'Success'
AUTH = 'http://fmi-autentificare.herokuapp.com'
