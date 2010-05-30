#!/usr/bin/ruby

Dir.chdir(File.dirname(__FILE__))

#Load libs
require "knj/autoload"

#Load config.
homedir = Knj::Os.homedir
data_dir = homedir + "/.knj/knjremoteserver"
$db_fn = homedir + "/.knj/knjremoteserver/knjremoteserver.sqlite3"

if !File.exists?(data_dir)
	print "Making config-dir in home...\n"
	FileUtils.mkdir_p(data_dir)
end

if !File.exists?($db_fn)
	print "Making database in config-dir...\n"
	FileUtils.copy("db/knjremoteserver.sqlite3", $db_fn)
end

$db = KnjDB.new(
	"type" => "sqlite3",
	"path" => $db_fn
)

require "windows/win_main.rb"
$win_main = WinMain.new

Gtk::main