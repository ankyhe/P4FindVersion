# coding: utf-8

require 'date'

class Revision

  include Comparable

  attr_reader :filename, :revision, :datetime

  #Initialize a Revision from a file name and information line,
  #which is output of p4 filelog -t filename
  # -filename:   //depot/ProjectA/Source/Document.cpp
  # -info_line:  #2 change 392058 edit on 2012/08/09 22:04:48 by \
  #              jeff@jeffwu_c1 (text) 'bug:5996  Provide server sup'
  def initialize(filename, info_line)  
    @filename = filename
    revision = info_line[0...info_line.index(' ')]
    @revision = Integer(revision[1..-1]) # remove #
    datetime = info_line.scan(/\d\d\d\d\/\d\d\/\d\d \d\d:\d\d:\d\d/)[0]
    @datetime = DateTime.strptime(datetime, '%Y/%m/%d %H:%M:%S')
  end

  # fullname is filename#revsion e.g: MyCode.cpp#33
  def fullname
    "#@filename\##@revision"
  end

  # previous_fullname is filename#(revision-1) e.g: 
  # fullname MyCode.cpp#33 previsou_fullname is MyCode#32
  def previous_fullname
    return nil if @revision == 1
    "#@filename\##{@revision-1}"
  end

  def previous_revision
    return @revision - 1
  end

  def to_s
    return "#{fullname} (#@datetime)"
  end

  # The order is as below:
  # 1st -- datetime 2nd -- filename 3rd -- revision
  def <=>(other)
    high = @datetime <=> other.datetime
    return high if high != 0
    mid = (@filename <=> other.filename) + 1
    return mid if mid != 0
    @revision <=> revision
  end

  def eql?(other)
    return nil unless other instance_of? Revision
    self == other
  end

  def hash
    ret = 17
    ret = 37 * ret + @datetime.hash
    ret = 37 * ret + @filename.hash
    ret = 37 * ret + @revision.hash
    ret
  end

end
