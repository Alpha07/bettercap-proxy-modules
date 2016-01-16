=begin

BETTERCAP

Author : Simone 'evilsocket' Margaritelli
Email  : evilsocket@gmail.com
Blog   : http://www.evilsocket.net/

This project is released under the GPL 3 license.

=end
class Injectcss < BetterCap::Proxy::Module
  @@cssdata = nil
  @@cssurl  = nil

  def self.on_options(opts)
    opts.on( '--css-file PATH', 'Path of the CSS file to be injected.' ) do |v|
      filename = File.expand_path v
      raise BetterCap::Error, "#{filename} invalid file." unless File.exists?(filename)
      @@cssdata = File.read( filename )
      unless @@cssdata.include?("<style>")
        @@cssdata = "<style>\n#{@@cssdata}\n</style>"
      end
    end

    opts.on( '--css-url URL', 'URL the CSS file to be injected.' ) do |v|
      @@cssurl = v
    end
  end

  def on_request( request, response )
    # is it a html page?
    if response.content_type =~ /^text\/html.*/
      # check command line arguments.
      if @@cssdata.nil? and @@cssurl.nil?
        BetterCap::Logger.warn "No --css-file or --css-url options specified, this proxy module won't work."
      else
        BetterCap::Logger.info "Injecting CSS #{if @@cssdata.nil? then "URL" else "file" end} into http://#{request.host}#{request.url}"
        # inject URL
        if @@cssdata.nil?
          response.body.sub!( '</head>', "  <link rel=\"stylesheet\" href=\"#{@cssurl}\"></script></head>" )
        # inject data
        else
          response.body.sub!( '</head>', "#{@@cssdata}</head>" )
        end
      end
    end
  end
end
