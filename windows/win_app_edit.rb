class WinAppEdit
	def initialize(paras)
		@paras = paras
		
		@glade = GladeXML.new("glade/win_app_edit.glade"){|handler|method(handler)}
		
		if (@paras["app"])
			@glade["txtTitle"].text = @paras["app"]["title"]
		end
		
		@glade["window"].show
	end
	
	def on_btnSave_clicked
		if (@paras["app"])
			$db.update("programs", {
				"title" => @glade.get_widget("txtTitle").text
			}, {"id" => @paras["app"]["id"]})
		else
			$db.insert("programs", {
				"title" => @glade.get_widget("txtTitle").text
			})
		end
		
		if (@paras["win_main"])
			@paras["win_main"].update_apps
		end
		
		@glade["window"].destroy
	end
	
	def on_btnCancel_clicked
		@glade["window"].destroy
	end
end