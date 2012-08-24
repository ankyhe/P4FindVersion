#! /usr/bin/env ruby
# coding: utf-8

$:.unshift File.dirname(File.expand_path((File.dirname(__FILE__))))

require 'test/unit'
require 'lib/revision'

class RevisionTest < Test::Unit::TestCase

  def test_to_s
    line = %q|#3 change 392314 edit on 2012/08/10 21:29:05 by jeff@jeff_c1 (text) 'bug:5996 update some memory '|
    r = Revision.new('//depot/abc.c', line)
    assert(r.to_s.include? '//depot/abc.c')
    assert(r.to_s.include? '2012-08-10')
    assert(r.to_s.include? '21:29:05')
  end

  def test_fullname
    line = %q|#3 change 392314 edit on 2012/08/10 21:29:05 by jeff@jeff_c1 (text) 'bug:5996 update some memory '|
    r = Revision.new('//depot/abc.c', line)
    assert_equal('//depot/abc.c#3', r.fullname)
  end

  def test_previous_fullname
    line = %q|#3 change 392314 edit on 2012/08/10 21:29:05 by jeff@jeff_c1 (text) 'bug:5996 update some memory '|
    r = Revision.new('//depot/abc.c', line)
    assert_equal('//depot/abc.c#2', r.previous_fullname)
  end

  def test_comparable
    line1 = %q|#3 change 392314 edit on 2012/08/10 21:29:05 by jeff@jeff_c1 (text) 'bug:5996 update some memory '|
    line2 = %q|#3 change 392314 edit on 2012/08/12 21:29:05 by jeff@jeff_c1 (text) 'bug:5996 update some memory '|
    line3 = %q|#3 change 392314 edit on 2012/08/10 02:29:05 by jeff@jeff_c1 (text) 'bug:5996 update some memory '|
    line4 = %q|#2 change 392314 edit on 2012/08/10 21:29:05 by jeff@jeff_c1 (text) 'bug:5996 update some memory '|
    r1 = Revision.new('//depot/abc.c', line1)
    r2 = Revision.new('//depot/abc.c', line2)
    r3 = Revision.new('//depot/abc.c', line3)
    r4 = Revision.new('//depot/abc.c', line4)
    arr = [r1, r2, r3, r4]
    arr.sort!
    arr2 = [r3, r4, r1, r2]
    assert_equal(arr, arr2)
  end

end
