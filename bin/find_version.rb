#! /usr/bin/env ruby
# coding: utf-8

$:.unshift File.dirname(File.expand_path((File.dirname(__FILE__))))

require 'open3'
require 'lib/revision_repos'
require 'lib/grep_text'
require 'lib/opt_parser'

INFO_CHAR = '*'
INFO_WIDTH = 80
INFO_LINE = INFO_CHAR * INFO_WIDTH

def show_info(title='', info='')
  print "#{INFO_CHAR*2}#{title}"
  puts "#{INFO_CHAR * (INFO_WIDTH - title.length)}" if INFO_WIDTH > title.length
  puts info if info.to_s.length > 0
end

def diff(revision)
  if revision.previous_fullname 
    local_filename = "/tmp/greptext_localcache_#{Process.pid}_#{revision.revision}"
    previous_local_filename = "/tmp/greptext_localcache_#{Process.pid}_#{revision.previous_revision}"
    ret1 = GrepText.download(revision.fullname, local_filename)
    ret2 = GrepText.download(revision.previous_fullname, previous_local_filename) if ret1 
    if ret2
      diff_tool = ENV['P4DIFF']
      diff_tool = '/usr/bin/vim -d' if diff_tool == nil or diff_tool.length == 0
      cmdline = "#{diff_tool} #{previous_local_filename} #{local_filename} &"
      show_info('Diff', cmdline)
      Open3.popen3(cmdline) {|stdin, stdout, stderr, wait_thr|}
    end
  end
end

def postprocess(revision)
  if revision != nil
    show_info('Found Revision', revision)
    cmdline = "p4 filelog -m 1 -l #{revision.fullname}" 
    show_info('Run command', cmdline)
    Open3.popen3(cmdline) do |stdin, stdout, stderr, wait_thr|
      if stderr.read != ''
        show_info('', "Failed to run #{cmdline}")
      else
        show_info('', stdout.read)
      end
    end
    diff(revision)
  else
    show_info('', 'NOT FOUND')
  end
end

def get_all_revisions(filename, verbose)
  revision_repos = RevisionRepos.new
  revision_repos.fetch_all_revision(filename)
  show_info('All Revisions', revision_repos.revisions) if verbose
  revision_repos
end


def grep(filename, text, delete_after_grep, verbose)
  gt = GrepText.new(delete_after_grep)
  revision_repos = get_all_revisions(filename, verbose)
  ret = grep_helper(filename, text, gt, revision_repos.revisions, 0, revision_repos.revisions.size-1)
  if !ret
    return nil
  else 
    return revision_repos.revisions[ret]
  end
end

def grep_helper(filename, text, grep_text, revisions, s, e)
  if s > e
    return nil
  elsif s == e
    if grep_text.grep(revisions[s].fullname, text)
      return s
    else
      return nil
    end
  else # s < e 
    mid = (e + s) / 2
    if grep_text.grep(revisions[mid].fullname, text)
      return grep_helper(filename, text, grep_text, revisions, s, mid-1) || mid
    else
      return grep_helper(filename, text, grep_text, revisions, mid+1, e)
    end
  end
end

def preprocess_text(text)
  ret = text.dup
  ret.gsub!('[', '\[')
  ret.gsub!('*', '\*')
  ret.gsub!('"', '\"')
  ret.gsub!('.', '\.')
  ret
end

def preprocess_path(filename, client_pattern)
  return filename, nil if (client_pattern == nil or filename.start_with? '//depot')
  absolute_path = File.expand_path(filename)
  client = absolute_path.scan(client_pattern)[0]
  return absolute_path, client
end

def main
  options = OptParser.parse(ARGV)
  absolute_path, client = preprocess_path(options.filename, options.client_pattern)
  ENV['P4CLIENT']=client if client
  if options.verbose
    show_info('Client', client) if client 
    show_info('Path', absolute_path)
  end
  if options.preprocess
    options.text = preprocess_text(options.text)
    if options.verbose
      show_info('Searching', "<---#{options.text}--->")
    end
  end
  revision = grep(absolute_path, options.text, true, options.verbose)
  postprocess(revision)
end

main
