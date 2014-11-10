require 'yaml'
require 'google_drive'

module TransyncConfig
  # Result of WORKSHEET_COLUMNS should be something like this
  # depends on LANGUAGES set in settings yaml file
  # WORKSHEET_COLUMNS = { key: 1, en: 2, de: 3 }
  WORKSHEET_COLUMNS = { key: 1 }
  START_ROW = 2

  @spreadsheet = nil
  @worksheets  = nil

  def self.init_spreadsheet
  #    session     = GoogleDrive.login(CONFIG['GDOC']['email'], CONFIG['GDOC']['password'])
    access_token = CONFIG['GDOC']['access_token']

    client_id = CONFIG['GDOC']['client_id']
    client_secret = CONFIG['GDOC']['client_secret']
    key = CONFIG['GDOC']['key']

    auth_token_string = CONFIG['auth_token']

    #puts "client_id:" + client_id.to_s
    #puts "client_secret:" + client_secret.to_s
    #puts "accessToken:" + CONFIG['GDOC']['accessToken'].to_s
    #puts "acctesTokenVar:" + accessToken.to_s
    

    client = OAuth2::Client.new(
      client_id, client_secret,
      :site => "https://accounts.google.com",
      :token_url => "/o/oauth2/token",
      :authorize_url => "/o/oauth2/auth")

    session = nil
    auth_token = nil

    if !auth_token_string
      auth_url = client.auth_code.authorize_url(
        :redirect_uri => "urn:ietf:wg:oauth:2.0:oob",
        :scope =>
            "https://docs.google.com/feeds/ " +
            "https://docs.googleusercontent.com/ " +
            "https://spreadsheets.google.com/feeds/")

        print("1. Open this page:\n%s\n\n" % auth_url)
        print("2. Enter the authorization code shown in the page: ")
        authorization_code = $stdin.gets.chomp

      auth_token = client.auth_code.get_token(
        authorization_code, :redirect_uri => "urn:ietf:wg:oauth:2.0:oob")
    else
      auth_token = OAuth2::AccessToken.from_hash(client, :refresh_token => auth_token_string).refresh!
      puts "Found access_token."
      puts auth_token.to_s
    end

    session = GoogleDrive.login_with_oauth(auth_token.token)

    # attempt to save auth_token
    #CONFIG['auth_token'] = auth_token
    d = YAML::load_file(File.open('transync.yml'))
    d['auth_token'] = auth_token.refresh_token
    File.open('transync.yml', 'w') {|f| f.write d.to_yaml }
  
    spreadsheet = session.spreadsheet_by_key(key)
    worksheets  = spreadsheet.worksheets

    return spreadsheet, worksheets
  end

  # This gets executed automatically when module is evaluated (required?)
  begin
    CONFIG = YAML.load(File.open('transync.yml'))
    @spreadsheet, @worksheets = TransyncConfig.init_spreadsheet

    # populate languages dynamically from settings yaml file
    CONFIG['LANGUAGES'].each_with_index do |language, index|
      key = language
      value = index + 2
      WORKSHEET_COLUMNS[key.to_sym] = value
    end
  rescue => e
    p e.message
    exit(1)
  end

  # used for init command after we create new tabs
  def self.re_init
    @spreadsheet, @worksheets = TransyncConfig.init_spreadsheet
  end

  def self.worksheets
    @worksheets
  end

  def self.spreadsheet
    @spreadsheet
  end

end
