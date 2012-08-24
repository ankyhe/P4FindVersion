# coding: utf-8                            

require 'optparse'
require 'ostruct'

class OptParser

  def self.parse(args)
    options = OpenStruct.new

    opts = OptionParser.new do |opts|
      opts.banner = 'Usage: find_version.rb [options]'
      opts.separator ''
      opts.separator 'options:'

      opts.on('-f', '--filename filename', 'searched file name') do |filename|
        options.filename = filename
      end

      opts.on('-t', '--text "search_text"', 'searching text') do |text|
        options.text = text
      end

      opts.on('-c', '--client client_pattern', 'p4 client pattern') do |cp|
        options.client_pattern = Regexp.new(cp)
      end

      opts.on('-p', '--preprocess"', 'preprocess text') do |p|
        options.preprocess = p
      end


      opts.on('-d', '--diff"', 'show diff with found revision and' + 
              ' its previous revision with $P4DIFF') do |d|
        options.diff = d
      end

      opts.on('-v', '--verbose"', 'show logger information') do |v|
        options.verbose = v
      end

      opts.separator ''
      opts.separator 'Example:'
      opts.separator "./find_version.rb -c ankyhe_c1 -f //depot/abc.m -t " +  
                     "'m_watched = @\"abc\" -f -v -d"
      opts.separator ''

    end

    opts.parse!(args)
    if options.filename == nil or options.text == nil
      puts opts
      exit
    end

    options
  end

end
