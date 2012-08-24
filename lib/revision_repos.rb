# coding: utf-8

require 'open3'
require 'lib/revision'

class RevisionRepos

  attr_accessor :revisions

  def initialize
    @filenames = {}
    @revisions = []
  end

  def fetch_all_revision(filename)
    fetch_all_revision_helper([filename])
    @revisions.sort!
  end

  private
  def fetch_all_revision_helper(filenames)
    new_filenames = []
    filenames.each do |filename| 
      next if @filenames.has_key? filename #filename has been resolved
      cmdline = "p4 filelog -t #{filename}" 
      Open3.popen3(cmdline) do |stdin, stdout, stderr, wait_thr|
        #
        # output is something like below:
        # $p4 filelog -t abc.cpp
        # //depot/abc.cpp
        # ... #3 change 392314 edit on 2012/08/10 21:29:05 by jeff@jeffwu_c1 (text) 'bug:5996 update some memory '
        # ... ... branch into //depot/dev2/abc.cpp#1
        # ... #2 change 392058 edit on 2012/08/09 22:04:48 by jeff@jeffwu_c2 (text) 'bug:5996  Provide server sup'
        #
        raise "Failed to run #{cmdline}" if stderr.read != ''
        @filenames[filename] = 1
        output = stdout.read
        lines = output.split(/\.\.\. /)
        lines.reject! {|line| line == ''}
        depot_filename = lines.shift # real_filename != filename due to filename maybe the name of workspace 
        @filenames[depot_filename] = 1
        lines.each do |line|
          if line.start_with? '#'
            revision = Revision.new(filename, line)
            @revisions << revision
          elsif line.start_with? 'branch'
            new_filename = line.scan(/\/\/depot\/.*?#/)[0].chop
            new_filenames << new_filename unless @filenames.has_key? new_filename
          end
        end
      end
    end
    fetch_all_revision_helper(new_filenames) unless new_filenames.empty?
  end
end
