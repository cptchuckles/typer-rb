#!/usr/bin/env ruby
# frozen_string_literal: true

typefilesdir = File.join(Dir.home, '.cache', 'typefiles')

files = `fd . "#{typefilesdir}" -d1 -H -X realpath`.split

file_lookup = {}
files.group_by { |f| f.split('/').last }.each do |_, paths|
  paths.map! { |path| path.split('/') }
  elide = paths.first[...-1].intersection(*paths).length - 1
  paths.each do |p|
    file_lookup[p[elide..].join('/')] = p.join '/'
  end
end

selection = IO.popen(['dmenu', '-l', '15', '-p', 'Type file:'], 'r+') do |dmenu|
  file_lookup.each_key do |short_path|
    dmenu.puts short_path
  end
  dmenu.close_write
  dmenu.gets
end

exit if selection.nil?
selection.chomp!

exit if file_lookup[selection].nil?

system('xdotool', 'type', '--clearmodifiers', '--file', file_lookup[selection])
