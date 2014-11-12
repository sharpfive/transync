require 'google_drive'
require 'colorize'

class GdocTransWriter

  def initialize(worksheet)
    @worksheet = worksheet
  end

  def write(trans_hash)
    #language    = trans_hash[:language]
    #abort("\u{2717} Language (#{language}) not found in worksheet '#{@worksheet.title}'!".colorize(:red)) if lang_column == 0

    row = 2

    puts "Rows to write:" + trans_hash[:translations].keys.count.to_s

    trans_hash[:translations].keys.each do |trans_key|
      trans_value = trans_hash[:translations][trans_key]
      @worksheet[row, 1] = trans_key['id'].to_s
      @worksheet[row, 2] = trans_value['source']
      @worksheet[row, 3] = trans_value['target']
      @worksheet[row, 4] = trans_value['note']
      @worksheet[row, 5] = trans_key['xcode_file']
      row += 1

      #puts "Key:" + trans_key.to_s
      # if row.modulo(10).zero?
      #   puts "saving worksheet row:" + row.to_s
      #   @worksheet.save
      # end
    end

    @worksheet.save
    
  end
end
