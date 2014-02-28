#require 'bundler/setup'
require_relative 'titlekit/lib/titlekit/parsers/ass'
require_relative 'titlekit/lib/titlekit/parsers/ssa'
require_relative 'titlekit/lib/titlekit/parsers/srt'

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

  def self.export(subtitles, filename, translated=true)
    data = case File.extname(filename)
           when '.ass'
             ASS.master(subtitles)
             ASS.export(subtitles, translated)
           when '.ssa'
             SSA.master(subtitles)
             SSA.export(subtitles, translated)
           when '.srt'
             SRT.master(subtitles)
             SRT.export(subtitles, translated)
           when '.yt'
             YT.master(subtitles)
             YT.export(subtitles, translated)
           end

    IO.write(filename, data)
  end
end
