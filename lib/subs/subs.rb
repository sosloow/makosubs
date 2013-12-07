require 'parsers/ass'
require 'parsers/srt'
require 'parsers/ssa'

module Subtitles
  def self.import(file)
    data = File.read(file, encoding: 'bom|utf-8')
    
    case File.extname(have.file)
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
             YT.export(want.subtitles)
           end

    IO.write(want.file, data)
  end
end
