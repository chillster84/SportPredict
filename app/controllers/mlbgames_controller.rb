class MlbgamesController < ApplicationController

	def index
		@mlbgames = Mlbgame.all
	end

	def show	
		@mlbgame = Mlbgame.find(params[:id])
		@stats = @mlbgame.attributes
		["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }
	end	

	def new
	require "open-uri"
  @mlbgame = Mlbgame.new
  #@stats = @mlbgame.attributes
	#["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }	
	
end

	def edit
		@mlbgame = Mlbgame.find(params[:id])
		@stats = @mlbgame.attributes
	["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }
	end

	def create
	require "open-uri"
		@mlbgame = Mlbgame.new(mlbgame_params)
		
	hitting_doc = Nokogiri::HTML(open("http://www.fangraphs.com/leaders.aspx?pos=all&stats=bat&lg=all&qual=0&type=c,41,71,50,61,111&season=2015&month=2&season1=2015&ind=0&team=0,ts&rost=0&age=0&filter=&players=0"))
	
		@hitting_table = hitting_doc.xpath('//*[@id="LeaderBoard1_dg1_ctl00"]/tbody')

		@hitting_table.css("tr").each do |row|
			@hitting_stats = row.css("td")
			if row.text.include? @mlbgame.away
				@mlbgame.a_babip = @hitting_stats[2].text.to_f
				@mlbgame.a_woba = @hitting_stats[4].text.to_f
				@mlbgame.a_wrc = @hitting_stats[5].text.to_f
				@mlbgame.a_bsr = @hitting_stats[6].text.to_f
			elsif row.text.include? @mlbgame.home
				@mlbgame.h_babip = @hitting_stats[2].text.to_f
				@mlbgame.h_woba = @hitting_stats[4].text.to_f
				@mlbgame.h_wrc = @hitting_stats[5].text.to_f
				@mlbgame.h_bsr = @hitting_stats[6].text.to_f
			end
		end
		
		a_sp_doc = Nokogiri::HTML(open("http://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=c,43,62,61&season=2015&month=3&season1=2015&ind=0&team=#{Mlbgame.teamID[@mlbgame.away]}&rost=0&age=0&filter=&players=0"))
	
		@a_sp_table = a_sp_doc.xpath('//*[@id="LeaderBoard1_dg1_ctl00"]/tbody')
		
		@a_sp_table.css("tr").each do |row|
			@a_sp_stats = row.css("td")
			if row.text.include? @mlbgame.a_name
				@mlbgame.a_sp_babip = @a_sp_stats[2].text.to_f
				@mlbgame.a_sp_xfip = @a_sp_stats[3].text.to_f
				@mlbgame.a_sp_tera = @a_sp_stats[4].text.to_f
			end
		end
		
		h_sp_doc = Nokogiri::HTML(open("http://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=c,43,62,61&season=2015&month=3&season1=2015&ind=0&team=#{Mlbgame.teamID[@mlbgame.home]}&rost=0&age=0&filter=&players=0"))
	
		@h_sp_table = h_sp_doc.xpath('//*[@id="LeaderBoard1_dg1_ctl00"]/tbody')
		
		@h_sp_table.css("tr").each do |row|
			@h_sp_stats = row.css("td")
			if row.text.include? @mlbgame.h_name
				@mlbgame.h_sp_babip = @h_sp_stats[2].text.to_f
				@mlbgame.h_sp_xfip = @h_sp_stats[3].text.to_f
				@mlbgame.h_sp_tera = @h_sp_stats[4].text.to_f
			end
		end
		
				
		relief_doc = Nokogiri::HTML(open("http://www.fangraphs.com/leaders.aspx?pos=all&stats=rel&lg=all&qual=0&type=c,62,43,74,66&season=2015&month=2&season1=2015&ind=0&team=0,ts&rost=0&age=0&filter=&players=0"))
		@relief_table = relief_doc.xpath('//*[@id="LeaderBoard1_dg1_ctl00"]/tbody')

		@relief_table.css("tr").each do |row|
			@relief_stats = row.css("td")
			if row.text.include? @mlbgame.away
				@mlbgame.a_rp_xfip = @relief_stats[2].text.to_f
				@mlbgame.a_rp_babip = @relief_stats[3].text.to_f
				@mlbgame.a_rp_re24 = @relief_stats[5].text.to_f
			elsif row.text.include? @mlbgame.home
				@mlbgame.h_rp_xfip = @relief_stats[2].text.to_f
				@mlbgame.h_rp_babip = @relief_stats[3].text.to_f
				@mlbgame.h_rp_re24 = @relief_stats[5].text.to_f
			end
		end
		
		def_doc = Nokogiri::HTML(open("http://www.fangraphs.com/leaders.aspx?pos=all&stats=fld&lg=all&qual=0&type=c,40&season=2015&month=0&season1=2015&ind=0&team=0,ts&rost=0&age=0&filter=&players=0"))
		@def_table = def_doc.xpath('//*[@id="LeaderBoard1_dg1_ctl00"]/tbody')

		@def_table.css("tr").each do |row|
			@def_stats = row.css("td")
			if row.text.include? @mlbgame.away
				@mlbgame.a_uzr150 = @def_stats[2].text.to_f
			elsif row.text.include? @mlbgame.home
				@mlbgame.h_uzr150 = @def_stats[2].text.to_f
			end
		end
		
		#prediction algorithm
		home_hitting = (0.5*((0.3-@mlbgame.h_babip)*1000)) + ((@mlbgame.h_woba-0.320)*1000) + (@mlbgame.h_wrc-100) + (0.5*((@mlbgame.h_bsr)*10))
		away_prevent = ((3.9-@mlbgame.a_sp_xfip)*100) + (0.5*((@mlbgame.a_sp_babip-0.300)*1000)) + ((4.3-@mlbgame.a_sp_tera)*100) + (0.5*(0.75*((@mlbgame.a_rp_babip-0.300)*1000))) + (0.75*((3.9-@mlbgame.a_rp_xfip)*100)) + (0.75*((@mlbgame.a_rp_re24)*10)) + (0.75*((@mlbgame.a_uzr150)*10))
		
		away_hitting = (0.5*((0.3-@mlbgame.a_babip)*1000)) + ((@mlbgame.a_woba-0.320)*1000) + (@mlbgame.a_wrc-100) + (0.5*((@mlbgame.a_bsr)*10))
		home_prevent = ((3.9-@mlbgame.h_sp_xfip)*100) + (0.5*((@mlbgame.h_sp_babip-0.300)*1000)) + ((4.3-@mlbgame.h_sp_tera)*100) + (0.5*(0.75*((@mlbgame.h_rp_babip-0.300)*1000))) + (0.75*((3.9-@mlbgame.h_rp_xfip)*100)) + (0.75*((@mlbgame.h_rp_re24)*10)) + (0.75*((@mlbgame.h_uzr150)*10))
		
		@mlbgame.h_pred = ((home_hitting - away_prevent)/100) + 4.16 #leage avg runs per game
		@mlbgame.a_pred = ((away_hitting - home_prevent)/100) + 4.16 #leage avg runs per game
		
		if @mlbgame.save
			redirect_to @mlbgame
		else 
			render 'new'
		end
	end
	
	def update
		@mlbgame = Mlbgame.find(params[:id])
		
		if @mlbgame.update(mlbgame_params)
			redirect_to @mlbgame
		else
			render 'edit'
		end
	end

	def destroy
		@mlbgame = Mlbgame.find(params[:id])
		@mlbgame.destroy
		
		redirect_to mlbgames_path
	end

	private
		def mlbgame_params
		  params.require(:mlbgame).permit(:home, :away, :date, :a_name, :h_name, :h_pred, :a_pred, :h_actual, :a_actual, :correct)
		end

end
