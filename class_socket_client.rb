class SocketClient
	def initialize(socket)
		begin
			debugprint("SocketClient started.\n")
			@socket = socket
			
			@db = Db.new(
				"type" => "sqlite3",
				"path" => $db_fn
			)
			
			f_gprograms = @db.select("programs", nil, {"orderby" => "title"});
			while d_gprograms = f_gprograms.fetch
				debugprint("Sending program " + d_gprograms["id"] + "\n")
				@socket.puts("program:" + d_gprograms["id"] + ":" + d_gprograms["title"] + "\n")
				
				f_gcmds = @db.select("programs_commands", {"program_id" => d_gprograms["id"]}, {"orderby" => "name"})
				while d_gcmds = f_gcmds.fetch
					debugprint("Sending command: " + d_gcmds["name"] + "\n")
					@socket.puts("cmd:" + d_gcmds["id"] + ":" + d_gcmds["name"] + "\n")
				end
				
				f_gsearches = @db.select("programs_searches", {"program_id" => d_gprograms["id"]}, {"orderby" => "title"})
				while d_gsearches = f_gsearches.fetch
					debugprint("Sending search: " + d_gsearches["title"] + "\n")
					@socket.puts("sch:" + d_gsearches["id"] + ":" + d_gsearches["title"] + "\n")
				end
			end
			
			@socket.send("endprogram\n", 0)
			
			while newline = @socket.gets
				debugprint("Awaiting new command.\n")
				self.validateCommand(newline)
			end
			
			debugprint("Closing socket.\n")
			@socket.close
		rescue => e
			debugputs(e.inspect)
			debugputs(e.backtrace)
		end
	end
	
	def readLine
		@string += @socket.recv(1)
		tha_index = string.index("\n")
		
		if tha_index != nil and tha_index > 0
			read = string.slice(0, tha_index)
			@string = @string.slice(tha_index..-1)
			return read
		end
		
		return nil
	end
	
	def validateCommand(command)
		line_arr = command.slice(0..-2).split(":");
		
		if command == "Hello knjRemoteServer\n"
			@socket.puts("Hello client\r\n")
		elsif line_arr[0] == "execute"
			cmd = @db.single("programs_commands", {"id" => line_arr[1]})
			
			if cmd
				debugprint("Command: " + cmd["server_command"] + "\n")
				
				Thread.new do
					system(cmd["server_command"])
				end
			end
		elsif line_arr[0] == "search"
			search = @db.single("programs_searches", {"id" => line_arr[1]})
			texts = line_arr[2].to_s.downcase.split(" ")
			
			@files = self.doSearch(
				"dir" => search["server_dir"],
				"ftypes" => search["filetypes"].downcase.split(";"),
				"texts" => texts
			)
			if @files.length > 15
				@files = @files.slice(0, 15)
			end
			
			count = 0
			@files.each do |filearr|
				@socket.puts("result:" + count.to_s + ":" + filearr["name"].gsub(":", "") + "\n")
				count += 1
			end
			
			@socket.puts("endresults\n")
		elsif line_arr[0] == "search_execute"
			search = @db.single("programs_searches", {"id" => line_arr[1]})
			file = @files[line_arr[2].to_i]
			
			if file and search
				filepath = "/"
				filearr = file["path"].split("/")
				filearr.each do |newpath|
					if filepath != "/"
						filepath += "/"
					end
					
					filepath += Strings.UnixSafe(newpath)
				end
				
				command = search["server_command"].gsub("%file", filepath)
				debugprint("Command: " + command + "\n")
				
				Thread.new do
					system(command)
				end
			end
		else
			debugprint("No match: " + command + "\n")
		end
	end
	
	def doSearch(paras)
		results = []
		
		Dir.new(paras["dir"]).entries.each do |fobject|
			if  fobject != "." and fobject != ".."
				fobject_dc = fobject.downcase
				fn = paras["dir"] + "/" + fobject
				
				if File.directory?(fn)
					newparas = paras.dup
					newparas["dir"] = paras["dir"] + "/" + fobject
					results = results | doSearch(newparas)
				else
					ext = File.extname(fobject.to_s).to_s.slice(1, 9).to_s
					
					if paras["ftypes"].index(ext)
						allfound = true
						paras["texts"].each do |text|
							res = fobject_dc.downcase.index(text)
							
							if res == nil
								allfound = false
							end
						end
						
						if allfound
							results[results.length] = {
								"name" => File.basename(fobject, "." + ext),
								"path" => fn
							}
						end
					end
				end
			end
		end
		
		return results
	end
end