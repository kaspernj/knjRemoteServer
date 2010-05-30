class WinCmdEdit
	def initialize(paras)
		@paras = paras
		
		require "libglade2"
		@glade = GladeXML.new("glade/win_cmd_edit.glade"){|handler|method(handler)}
		
		if (@paras["command"])
			@glade.get_widget("txtTitle").text = @paras["command"]["name"]
			@glade.get_widget("txtCommand").text = @paras["command"]["server_command"]
			@glade.get_widget("txtShortcutKey").text = @paras["command"]["mobile_key"]
		end
		
		@glade.get_widget("window").show
	end
	
	def on_btnSave_clicked
		save_hash = {
			"program_id" => @paras["app"]["id"],
			"name" => @glade.get_widget("txtTitle").text,
			"server_command" => @glade.get_widget("txtCommand").text,
			"mobile_key" => @glade.get_widget("txtShortcutKey").text
		}
		
		if (@paras["command"])
			$db.update("programs_commands", save_hash, {"id" => @paras["command"]["id"]})
		else
			$db.insert("programs_commands", save_hash)
		end
		
		if (@paras["win_main"])
			@paras["win_main"].update_commands
		end
		
		@glade.get_widget("window").destroy
	end
	
	def on_btnCancel_clicked
		@glade.get_widget("window").destroy
	end
end