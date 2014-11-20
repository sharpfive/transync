require 'colorize'
require_relative '../transync_config'

class GdocTransReader
  #attr_reader :worksheet

  # file represents tab in spreadsheet
  def initialize(file)
    @file
  end

  def worksheet_for_language(language)
    worksheet = TransyncConfig.worksheets.detect{ |w| w.title.casecmp(language) == 0}
    abort("\u{2717} '#{language} tab is not defined in GDoc".colorize(:red)) if worksheet.nil?
    worksheet
  end

  def translations(language)
    worksheet = worksheet_for_language(language)

    trans_hash = { file: @file, language: language, translations: {} }
    key_column      = 1 #TransyncConfig::WORKSHEET_COLUMNS[:key]
    source_column = 2
    target_column = 3
    note_column = 4
    xcode_file_column = 5
    #language_column = TransyncConfig::WORKSHEET_COLUMNS[language.to_sym]

    (TransyncConfig::START_ROW..worksheet.num_rows).to_a.each do |row|
      xcode_file_value = worksheet[row, xcode_file_column]
      id_value = worksheet[row, key_column]
      if (id_value.to_s.empty? || xcode_file_value.to_s.empty?)
        #puts "Skipping row:" + row.to_s
        next
      end

      key   = { 
                'xcode_file' => xcode_file_value,
                'id' => id_value
              }

      value = {
                'target' => worksheet[row, target_column],
                'source' => worksheet[row, source_column],
                'note' => worksheet[row, note_column]
              }
      #puts "Reading from gdoc:" + key.to_s + value.to_s
      trans_hash[:translations][key] = value
    end

    trans_hash
  end

end
