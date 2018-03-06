module Fontora
 module Site
  class Parser
   include Celluloid
   include Fontora::Utils::Methods
   ROOT_PATH        = File.expand_path(File.join(File.dirname(__FILE__), '../../../'))
   PARSER_PATH      = ROOT_PATH + '/nodejs/parser'
   PIPE_PARSER_PATH = ROOT_PATH + '/nodejs/pipe-parser'
   TEMP_PATH        = ROOT_PATH + '/tmp/'
   KERNEL_MAX_ARG   = `getconf ARG_MAX`.chomp.to_i  #> Max commandline arg limited by kernel

   def get_font_info font_uri, host, source, root_uri
    font_file = download_with_path font_uri
    info = get_font_data font_file
    { host: host, stylesheet_uri: source, font_uri: font_uri, info: info, 
        source: get_source(font_uri.to_s, source, root_uri) }
   end

   def download_with_path font_uri
    data = get_data font_uri.to_s
    hex = data.unpack("H*")[0]
    if hex.bytesize < KERNEL_MAX_ARG
     Logger.info 'Saved font data with bytesize: ' + hex.bytesize.to_s
     {type: :raw, data: hex}
    else
     filename = TEMP_PATH + SecureRandom.uuid
     File.open(filename, 'wb') { |file| file.write data }
     Logger.info 'Saved font to: ' + filename
     {type: :file, data: filename}
    end
   rescue => e
    Logger.error 'Error downloading font | Reason: ' + e.message
    nil
   end

   def get_data font_uri
    return Base64.decode64(font_uri.split('base64,').last) if base64? font_uri
    open(font_uri, allow_redirections: :safe).read
   end

   def base64? uri
    uri.include?('base64')
   end

   def get_font_data file
    return nil unless file
    if file[:type] == :raw
     Logger.info 'Running: ' + PIPE_PARSER_PATH + ' Size: ' + file[:data].bytesize.to_s
     json = JSON.parse( %x[ echo #{ file[:data] } | #{ PIPE_PARSER_PATH } ] ).deep_symbolize_keys rescue nil
     json
    else
     Logger.info 'Running: ' + PARSER_PATH + ' ' + file[:data]
     json = JSON.parse( %x[ #{ PARSER_PATH } #{ file[:data] } ] ).deep_symbolize_keys rescue nil
     File.delete(file[:data])
     json
    end
   rescue => e
    Logger.error 'Error getting font data | Reason: ' + e.message
    nil
   end

   def get_source font_uri, source, root_uri
    return nil unless source
    root_uri == root_domain(font_uri) ? 'internal' : 'external'
   end

  end
 end
end