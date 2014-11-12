require 'colorize'

class Init

  def initialize(path)
    @path   = path
    @config = TransyncConfig::CONFIG
  end

  def run
    #@config['FILES'].each do |file|
      file = @config['GDOC_FILE_NAME']
      languages = @config['LANGUAGES']
      
      @config['LANGUAGES'].each_with_index do |language, index|
        worksheet = TransyncConfig.worksheets.detect{ |s| s.title.casecmp(language) == 0 }
        if worksheet.nil?
          puts "\u{2713} adding '#{language}' worksheet to spreadsheet)".colorize(:green)
          worksheet = TransyncConfig.spreadsheet.add_worksheet(language)
          
        end

        worksheet[1, 1] = 'key'
        worksheet[1, 2] = 'english'
        worksheet[1, 3] = 'translation'
        worksheet[1, 4] = 'comment'
        worksheet[1, 5] = 'file'
    
        worksheet.save
      end
     
    #end

    # re-init spreadsheet after new worksheets were created
    TransyncConfig.re_init
    sync = TranslationSync.new(@path, 'x2g')
    sync.run('x2g')
  end

end
