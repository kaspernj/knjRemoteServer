class WinMain
	def initialize
		@glade = GladeXML.new("glade/win_main.glade"){|handler|method(handler)}
		
		@tv_apps = @glade["tvApps"]
		@tv_apps.init(["ID", "Title"])
		@tv_apps.columns[0].visible = false
		
		@tv_apps.selection.signal_connect("changed") do |selection|
			on_tvApps_changed
		end
		
		@tv_searches = @glade["tvSearches"]
		@tv_searches.init(["ID", "Title"])
		@tv_searches.columns[0].visible = false
		
		@tv_commands = @glade["tvCommands"]
		@tv_commands.init(["ID", "Title"])
		@tv_commands.columns[0].visible = false
		
		update_apps
		
		@glade["window"].show_all
	end
	
	def window
		return @glade["window"]
	end
	
	def update_apps
		@tv_apps.model.clear
		f_gapps = $db.select("programs", nil, {"orderby" => "title"})
		while d_gapps = f_gapps.fetch
			@tv_apps.append([d_gapps["id"], d_gapps["title"]])
		end
	end
	
	def update_commands
		program = @tv_apps.sel
		
		@tv_commands.model.clear
		if program
			f_gcmds = $db.select("programs_commands", {"program_id" => program[0]}, {"orderby" => "name"})
			while d_gcmds = f_gcmds.fetch
				@tv_commands.append([d_gcmds["id"], d_gcmds["name"]])
			end
		end
	end
	
	def update_searches
		program = @tv_apps.sel
		
		if program
			@tv_searches.model.clear
			f_gsearches = $db.select("programs_searches", {"program_id" => program[0]}, {"orderby" => "title"})
			while d_gsearches = f_gsearches.fetch
				@tv_searches.append([d_gsearches["id"], d_gsearches["title"]])
			end
		end
	end
	
	def on_window_destroy
		Gtk.main_quit
	end
	
	def on_tvApps_changed
		update_commands
		update_searches
	end
	
	def on_btnAppAdd_clicked
		WinAppEdit.new("win_main" => self)
	end
	
	def selected_app
		app_row = @tv_apps.sel
		if !app_row
			msgbox("Please select an application and try again.")
			return nil
		end
		
		app_data = $db.selectsingle("programs", {"id" => app_row[0]})
		if !app_data
			msgbox("That application does not exist.")
			return nil
		end
		
		return {
			"row" => app_row,
			"data" => app_data
		}
	end
	
	def selected_command
		cmd_row = @tv_commands.sel
		if !cmd_row
			msgbox("Please select a command and try again.")
			return nil
		end
		
		cmd_data = $db.selectsingle("programs_commands", {"id" => cmd_row[0]})
		if !cmd_data
			msgbox("That command does not exist in the database.")
			return nil
		end
		
		return {
			"row" => cmd_row,
			"data" => cmd_data
		}
	end
	
	def selected_search
		search_row = @tv_searches.sel
		if !search_row
			msgbox("Please select a search and try again.")
			return nil
		end
		
		search_data = $db.selectsingle("programs_searches", {"id" => search_row[0]})
		if !search_data
			msgbox("That search does not exist in the database.")
			return nil
		end
		
		return {
			"row" => search_row,
			"data" => search_data
		}
	end
	
	def on_btnAppEdit_clicked
		app = selected_app
		if !app
			return nil
		end
		
		WinAppEdit.new("win_main" => self, "app" => app["data"])
	end
	
	def on_btnAppDelete_clicked
		app = selected_app
		if !app
			return nil
		end
		
		if msgbox("Do you want to delete the selected application?", "yesno") == "yes"
			$db.delete("programs_commands", {"program_id" => app["data"]["id"]})
			$db.delete("programs_searches", {"program_id" => app["data"]["id"]})
			$db.delete("programs", {"id" => app["data"]["id"]})
			update_apps
		end
	end
	
	def on_btnCmdAdd_clicked
		app = selected_app
		if !app
			return nil
		end
		
		WinCmdEdit.new("win_main" => self, "app" => app["data"])
	end
	
	def on_btnCmdEdit_clicked
		command = selected_command
		if !command
			return nil
		end
		
		app = selected_app
		if !app
			return nil
		end
		
		WinCmdEdit.new("win_main" => self, "command" => command["data"], "app" => app["data"])
	end
	
	def on_btnCmdDelete_clicked
		command = selected_command
		if !command
			return nil
		end
		
		if msgbox("Do you want to delete the selected command?", "yesno") == "yes"
			$db.delete("programs_commands", {"id" => command["data"]["id"]})
			update_commands
		end
	end
	
	def on_btnSearchAdd_clicked
		app = selected_app
		if !app
			return nil
		end
		
		WinSearchEdit.new("win_main" => self, "app" => app["data"])
	end
	
	def on_btnSearchEdit_clicked
		search = selected_search
		if !search
			return nil
		end
		
		app = selected_app
		if !app
			return nil
		end
		
		WinSearchEdit.new("win_main" => self, "search" => search["data"], "app" => app["data"])
	end
	
	def on_btnSearchDelete_clicked
		search = selected_search
		if !search
			return nil
		end
		
		if msgbox("Do you want to delete the selected search?", "yesno") == "yes"
			$db.delete("programs_searches", {"id" => search["data"]["id"]})
			update_searches
		end
	end
end