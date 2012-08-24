# coding: utf-8

require 'open3'

class GrepText

  def initialize(delete_after_grep=true)
    @local_filename = "/tmp/greptext_localcache_#{Process.pid}"
    @delete_after_grep = delete_after_grep
  end

  def grep(fullname, text)
    if download(fullname)
      cmdline = %Q|grep -i "#{text}" #@local_filename|
      Open3.popen3(cmdline) do |stdin, stdout, stderr, wait_thr|
        if stderr.read != ''
          raise "Failed to run #{cmdline}"
        end
        File.delete(@local_filename) if @delete_after_grep
        if stdout.read != ''
          true
        else
          false
        end
      end
    else
      false
    end
  end

  def download(fullname)
    GrepText.download(fullname, @local_filename)
  end

  def self.download(fullname, local_filename)
    cmdline = "p4 print -o #{local_filename} #{fullname}"
    Open3.popen3(cmdline) do |stdin, stdout, stderr, wait_thr|
      err = stderr.read
      if err  != ''
        if err.include? 'no file(s) at that revision'
          puts "Failed to run #{cmdline}"
          false
        else
          raise "Failed to run #{cmdline}"
        end
      else
        true
      end
    end
  end

  private :download

end
