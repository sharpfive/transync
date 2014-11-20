require 'logger'
require_relative '../xliff_trans/xliff_trans_reader'

module SyncUtil

  def self.info_clean(file, language, message)
    msg = "#{file} (#{language}) - #{message}"
    SyncUtil.log_and_puts(msg)
  end

  def self.info_diff(file, language, diff, diff_only = nil)
    msg = ''

    unless diff.empty?
      msg = "#{file} (#{language})\n" if not diff_only
      msg = build_diff_print(diff, msg, diff_only)
    end
    SyncUtil.log_and_puts(msg)
  end

  def self.build_diff_print(diff, msg, diff_only = nil)
    begin
      # get longest key and value
      max_key_length = diff.keys.max { |a, b| a.length <=> b.length }.length
      max_val_length = diff.values.max { |a, b| a[1].to_s.length <=> b[1].to_s.length }[1].length
    rescue
      max_key_length = 0
      max_val_length = 0
    end

    newline = ''
    diff.keys.each do |key|
      change_mark = ' => '
      operation = diff[key][1].nil? ? 'adding' : 'changing'
      ljust = 8

      key_file = key['xcode_file'].to_s
      key_id = key['id'].to_s

      if diff_only
        operation = 'diff'
        change_mark = ' <=> '
        ljust = 4

        xcode_file = diff[key][0]['target']

        gdoc_file = nil

        if !diff[key][1].nil?
          gdoc_file = diff[key][1]['target']
        end

        msg += "#{newline}[#{operation.ljust(ljust)}] #{key_id} - xcode_file:#{xcode_file}  gdoc_file:#{gdoc_file}"
        next
      end

      
      new_value = diff[key][0]['target']

      old_value = nil
      if !diff[key][1].nil?
        old_value= diff[key][1]['target']
      end
      
      msg += "#{newline}[#{operation.ljust(ljust)}] #{key_id} - new value:#{new_value}  old value:#{old_value}"
 
      newline = "\n"
    end
    msg
  end

  def self.log_and_puts(msg)
    puts msg unless msg.length == 0
    @logger.info msg
  end

  def self.create_logger(direction)
    @logger = Logger.new(".transync_log/#{direction}.log", 'monthly')
  end

end
