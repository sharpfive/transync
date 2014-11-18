require 'builder'

class XliffTransWriter
  attr_accessor :path,
                :file

  def initialize(path, file)
    self.path = path
    self.file = file
  end

  def write(trans_hash)
    language     = trans_hash[:language]
    translations = trans_hash[:translations]

    xcode_files = translations.keys.each.group_by{ |key| key['xcode_file'] }
    puts "xcode_files:" + xcode_files.count.to_s

    xml = Builder::XmlMarkup.new( :indent => 4 )
    xml.instruct! :xml, :encoding => 'UTF-8'


    xml.xliff :version => '1.2', :xmlns => 'urn:oasis:names:tc:xliff:document:1.2' do |xliff|
      #xml.files do
        xcode_files.each do |key, group_array|
          xliff.file :original => key, :'source-language' => "en", :datatype => 'plaintext', :'target-language' => language  do |file|
            file.header do |header| #:'tool-id' => "buzzsync", :'tool-name' => "BuzzFeed XLiffMapper", :'build-num' => 0
              header.tool :'tool-id' => "com.buzzfeed.buzzsync", :'tool-name' => "BuzzFeed XLiffMapper", :'build-num' => 0
            end
            file.body do |body|
              group_array.each do | trans_element |
                file_name = trans_element['xcode_file']
                id = trans_element['id']
                translation_value = translations[trans_element]
                body.tag! 'trans-unit', :id => id do |trans_unit|
                  trans_unit.source translation_value['source']
                  trans_unit.target translation_value['target']
                  trans_unit.note translation_value['note']
                end
              end
            end
          end
        end
      #end #xml files do
    end

    File.open(file_path(language), 'w') { |file| file.write(xml.target!) }
  end

private

  def file_path(language)
    if self.file.to_s.empty?
      "#{path}/#{language}.xliff"
    else
      "#{path}/#{file}.#{language}.xliff"
    end
  end

end
