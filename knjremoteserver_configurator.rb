#!/usr/bin/ruby

Dir.chdir(File.dirname(__FILE__))

#Load libs
require "knj/autoload"
include Knj

require "knj/gtk2"
require "knj/gtk2_tv"

autoload :WinMain, "windows/win_main"
autoload :WinAppEdit, "windows/win_app_edit"
autoload :WinCmdEdit, "windows/win_cmd_edit"
autoload :WinSearchEdit, "windows/win_search_edit"

#Load config.
homedir = Os.homedir
data_dir = homedir + "/.knj/knjremoteserver"
$db_fn = homedir + "/.knj/knjremoteserver/knjremoteserver.sqlite3"

if !File.exists?(data_dir)
	print "Making config-dir in home...\n"
	FileUtils.mkdir_p(data_dir)
end

if !File.exists?($db_fn)
	print "Making database in config-dir...\n"
	FileUtils.copy("db/knjremoteserver_sample.sqlite3", $db_fn)
end

$db = Db.new(
	"type" => "sqlite3",
	"path" => $db_fn
)

$win_main = WinMain.new
Gtk.main