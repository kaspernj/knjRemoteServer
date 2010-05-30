#!/usr/bin/ruby

Dir.chdir(File.dirname(__FILE__))

#Load libs.
require "knj/autoload"
include Knj

autoload :SocketClient, "class_socket_client.rb"


def debugputs(object)
	if ($opts["debug"])
		puts(object)
	end
end

def debugprint(msg)
	if ($opts["debug"])
		print(msg)
	end
end


#Parse arguments.
$opts = {
	"debug" => false,
	"nothreads" => false,
	"port" => 8242
}
count = 0
ARGV.each do |value|
	if (value == "--debug")
		print("Debug-mode activated.\n")
		$opts["debug"] = true
	elsif (value == "--port")
		print("Using non-standard port: " + ARGV[count + 1] + "\n")
		$opts["port"] = ARGV.to_a[count + 1].to_i
	elsif (value == "--nothreads")
		print("Using no-threads.\n")
		$opts["nothreads"] = true
	end
	
	count += 1
end



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



#Open port.
clients = []
ss = TCPServer.new("0.0.0.0", $opts["port"])

print "Waiting for connections...\n"

loop do
	s = ss.accept
	print s, " is accepted\n"
	
	if ($opts["nothreads"])
		clients[clients.length] = SocketClient.new(s)
	else
		Thread.new(s) do
			clients[clients.length] = SocketClient.new(s)
		end
	end
end