# Change this omniauth configuration to point to your registered provider
# Since this is a registered application, add the app id and secret here
APP_ID = '8ef70bf5-3019-426e-ae33-8fc91821eaab'
APP_SECRET = 'e530eab41f854cfc67d4b9d13768c87b4fe0f196bd300b51f0'

CUSTOM_PROVIDER_URL = 'http://fmi-autentificare.herokuapp.com'

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :autentificare, APP_ID, APP_SECRET
end
