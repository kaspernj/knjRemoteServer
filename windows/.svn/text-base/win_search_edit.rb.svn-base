class WinSearchEdit
	def initialize(paras)
		@paras = paras
		
		print_r(@paras["app"])
		
		require "libglade2"
		@glade = GladeXML.new("glade/win_search_edit.glade"){|handler|method(handler)}
		
		if (@paras["search"])
			@glade.get_widget("txtTitle").text = @paras["search"]["title"]
			@glade.get_widget("txtCommand").text = @paras["search"]["server_command"]
			@glade.get_widget("txtDir").text = @paras["search"]["server_dir"]
			@glade.get_widget("txtShortcutKey").text = @paras["search"]["mobile_key"]
			@glade.get_widget("txtFileTypes").text = @paras["search"]["filetypes"]
		end
		
		@glade.get_widget("window").show_all
	end
	
	def on_btnSave_clicked
		save_hash = {
			"program_id" => @paras["app"]["id"],
			"title" => @glade.get_widget("txtTitle").text,
			"server_command" => @glade.get_widget("txtCommand").text,
			"server_dir" => @glade.get_widget("txtDir").text,
			"mobile_key" => @glade.get_widget("txtShortcutKey").text,
			"filetypes" => @glade.get_widget("txtFileTypes").text
		}
		
		print_r(save_hash)
		
		if (@paras["search"])
			$db.update("programs_searches", save_hash, {"id" => @paras["search"]["id"]})
		else
			$db.insert("programs_searches", save_hash)
		end
		
		if (@paras["win_main"])
			@paras["win_main"].update_searches
		end
		
		@glade.get_widget("window").destroy
	end
	
	def on_btnCancel_clicked
		@glade.get_widget("window").destroy
	end
end