require_relative '../gdoc_trans/gdoc_trans_reader'
require_relative '../gdoc_trans/gdoc_trans_writer'
require_relative '../xliff_trans/xliff_trans_writer'
require_relative '../../hash'

class TranslationSync

  def initialize(path, direction, file = nil)
    @path   = path
    @file   = file
    @config = TransyncConfig::CONFIG
    @gdoc_file = @config['GDOC_FILE_NAME']
    SyncUtil.create_logger(direction)
  end

  def run(direction)
    @config['FILES'].each do |file|
      
      languages = @config['LANGUAGES']

      xliff_files = XliffTransReader.new(@path, file, @config['LANGUAGES'])
      abort('Fix your Xliff translations by hand or run transync update!') unless xliff_files.valid?

      gdoc_trans_reader  = GdocTransReader.new(@gdoc_file)

      @config['LANGUAGES'].each do |language|

        worksheet = gdoc_trans_reader.worksheet_for_language(language)
        
        gdoc_trans_writer  = GdocTransWriter.new(worksheet)

        xliff_trans_writer = XliffTransWriter.new(@path, file)

        trans_sync = TranslationSync.new(@path, direction, file)
        trans_hash = trans_sync.sync(language, direction)

        puts "Begin write"
        if direction == 'x2g'
          gdoc_trans_writer.write(trans_hash)
        else
          xliff_trans_writer.write(trans_hash)
        end
      end
    end
  end

  def sync(language, direction)

    gdoc_trans_reader  = GdocTransReader.new(@gdoc_file)
    xliff_trans_reader = XliffTransReader.new(@path, @file, nil) # we dont need languages for translations method

    g_trans_hash = gdoc_trans_reader.translations(language)
    x_trans_hash = xliff_trans_reader.translations(language)

    # We need to merge on translations hash, not whole hash since it will only merge first level
    if direction == 'x2g'
      merged_translations = g_trans_hash[:translations].merge(x_trans_hash[:translations])
      diff = x_trans_hash[:translations].diff(g_trans_hash[:translations])
      SyncUtil.info_diff(@file, language, diff)
    else
      merged_translations = x_trans_hash[:translations].merge(g_trans_hash[:translations])
      diff = g_trans_hash[:translations].diff(x_trans_hash[:translations])
      SyncUtil.info_diff(@file, language, diff)
    end

    {file: @file, gdoc_file: @gdoc_file, language: language, translations: merged_translations}
  end

  def diff(language)
    gdoc_trans_reader  = GdocTransReader.new(@gdoc_file)
    xliff_trans_reader = XliffTransReader.new(@path, @file, nil)

    g_trans_hash = gdoc_trans_reader.translations(language)
    x_trans_hash = xliff_trans_reader.translations(language)

    diff = x_trans_hash[:translations].diff(g_trans_hash[:translations])
    SyncUtil.info_diff(@file, language, diff, true)
    diff
  end

end
