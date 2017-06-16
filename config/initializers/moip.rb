# Get the user credentials
auth = Moip2::Auth::Basic.new(Rails.application.secrets.moip_token, Rails.application.secrets.moip_secret)
# Pick a moip environment
client = Moip2::Client.new(Rails.application.secrets.moip_environment.to_sym, auth)
# Generates the access object
::MoipApi = Moip2::Api.new(client)
