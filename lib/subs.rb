#require 'bundler/setup'
require_relative 'titlekit/lib/titlekit/parsers/ass'
require_relative 'titlekit/lib/titlekit/parsers/ssa'

module Subtitles

  include Titlekit
  
  def self.import(tmpfile, filename)
    data = File.read(tmpfile.path, encoding: 'bom|utf-8')
    
    case File.extname(filename)
    when '.ass'
      ASS.import(data)
    when '.ssa'
      SSA.import(data)
    when '.srt'
      SRT.import(data)
    when '.yt'
      YT.import(data)
    end
  end

  def self.export(subtitles, file)
    data = case File.extname(file)
           when '.ass'
             ASS.master(subtitles)
             ASS.export(subtitles)
           when '.ssa'
               SSA.master(subtitles)
             SSA.export(subtitles)
           when '.srt'
             SRT.master(subtitles)
             SRT.export(subtitles)
           when '.yt'
             YT.master(subtitles)
             YT.export(subtitles)
           end

    IO.write(file, data)
  end
end
