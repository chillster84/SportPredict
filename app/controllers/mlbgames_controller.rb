class MlbgamesController < ApplicationController

	def index
		@mlbgames = Mlbgame.all
		@correct = ( (@mlbgames.sum(:correct).to_f) / (@mlbgames.where("correct IS NOT NULL").count.to_f) * 100 ).round
		@correct2 = ( (@mlbgames.sum(:correct2).to_f) / (@mlbgames.where("correct2 IS NOT NULL").count.to_f) * 100 ).round rescue 0
    0.0
	end

	def show	
		@mlbgame = Mlbgame.find(params[:id])
		@stats = @mlbgame.attributes
		["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }
	end	

	def new
	
	require "open-uri"
  @mlbgames = []
  #@stats = @mlbgame.attributes
	#["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }	
	
	schedule = Nokogiri::HTML(open("http://m.espn.go.com/wireless/scoreboard?wjb"))
	@games = schedule.xpath("//*[substring(@id, 1, 4) = 'game']/div/a")
	@games.each do |game|
		if ((game['href'].include? "mlb") && (game.text.include? "PM"))
			@mlbgame = Mlbgame.new
			@mlbgame.date = Time.now.strftime("%d/%m/%Y")
			@mlbgame.away = Mlbgame.teamShort[game.text.split(" ")[0]]
			@mlbgame.home = Mlbgame.teamShort[game.text.partition('at ').last.split(" ")[0]]
			starters_doc = Nokogiri::HTML(open("http://m.espn.go.com#{game['href']}"))
			@mlbgame.a_name = starters_doc.xpath("//*/div/b/a")[0].text
			@mlbgame.h_name = starters_doc.xpath("//*/div/b/a")[1].text
			@mlbgames << @mlbgame
		end
	end 
	
	#have all the games. Get data and save each one
	@mlbgames.each do |mlbgame|
	hitting_doc = Nokogiri::HTML(open("http://www.fangraphs.com/leaders.aspx?pos=all&stats=bat&lg=all&qual=0&type=c,41,71,50,61,111&season=2015&month=2&season1=2015&ind=0&team=0,ts&rost=0&age=0&filter=&players=0"))
	
		@hitting_table = hitting_doc.xpath('//*[@id="LeaderBoard1_dg1_ctl00"]/tbody')

		@hitting_table.css("tr").each do |row|
			@hitting_stats = row.css("td")
			if row.text.include? mlbgame.away
				mlbgame.a_babip = @hitting_stats[2].text.to_f
				mlbgame.a_woba = @hitting_stats[4].text.to_f
				mlbgame.a_wrc = @hitting_stats[5].text.to_f
				mlbgame.a_bsr = @hitting_stats[6].text.to_f
			elsif row.text.include? mlbgame.home
				mlbgame.h_babip = @hitting_stats[2].text.to_f
				mlbgame.h_woba = @hitting_stats[4].text.to_f
				mlbgame.h_wrc = @hitting_stats[5].text.to_f
				mlbgame.h_bsr = @hitting_stats[6].text.to_f
			end
		end
		
		a_sp_doc = Nokogiri::HTML(open("http://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=c,43,62,61&season=2015&month=3&season1=2015&ind=0&team=#{Mlbgame.teamID[mlbgame.away]}&rost=0&age=0&filter=&players=0"))
	
		@a_sp_table = a_sp_doc.xpath('//*[@id="LeaderBoard1_dg1_ctl00"]/tbody')
		
		@a_sp_table.css("tr").each do |row|
			@a_sp_stats = row.css("td")
			if (@a_sp_stats[1].text.downcase.include? mlbgame.a_name.split(" ", 2)[1].downcase) && ( @a_sp_stats[1].text[0] == mlbgame.a_name[0])
				mlbgame.a_sp_babip = @a_sp_stats[2].text.to_f
				mlbgame.a_sp_xfip = @a_sp_stats[3].text.to_f
				mlbgame.a_sp_tera = @a_sp_stats[4].text.to_f
			end
		end
		
		#if not in team list, probably ML debut or coming off long injury. Too unpredictable, use league averages.
		if (mlbgame.a_sp_babip.nil?)
			mlbgame.a_sp_babip = 0.3
			mlbgame.a_sp_xfip = 3.9
			mlbgame.a_sp_tera = 4.3
		end
		
		h_sp_doc = Nokogiri::HTML(open("http://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=c,43,62,61&season=2015&month=3&season1=2015&ind=0&team=#{Mlbgame.teamID[mlbgame.home]}&rost=0&age=0&filter=&players=0"))
	
		@h_sp_table = h_sp_doc.xpath('//*[@id="LeaderBoard1_dg1_ctl00"]/tbody')
		
		@h_sp_table.css("tr").each do |row|
			@h_sp_stats = row.css("td")
			if (@h_sp_stats[1].text.downcase.include? mlbgame.h_name.split(" ", 2)[1].downcase) && (@h_sp_stats[1].text[0] == mlbgame.h_name[0])
				mlbgame.h_sp_babip = @h_sp_stats[2].text.to_f
				mlbgame.h_sp_xfip = @h_sp_stats[3].text.to_f
				mlbgame.h_sp_tera = @h_sp_stats[4].text.to_f
			end
		end
		
		#if not in team list, probably ML debut or coming off long injury. Too unpredictable, use league averages.
		if (mlbgame.h_sp_babip.nil?)
			mlbgame.h_sp_babip = 0.3
			mlbgame.h_sp_xfip = 3.9
			mlbgame.h_sp_tera = 4.3
		end
		
				
		relief_doc = Nokogiri::HTML(open("http://www.fangraphs.com/leaders.aspx?pos=all&stats=rel&lg=all&qual=0&type=c,62,43,74,66&season=2015&month=2&season1=2015&ind=0&team=0,ts&rost=0&age=0&filter=&players=0"))
		@relief_table = relief_doc.xpath('//*[@id="LeaderBoard1_dg1_ctl00"]/tbody')

		@relief_table.css("tr").each do |row|
			@relief_stats = row.css("td")
			if row.text.include? mlbgame.away
				mlbgame.a_rp_xfip = @relief_stats[2].text.to_f
				mlbgame.a_rp_babip = @relief_stats[3].text.to_f
				mlbgame.a_rp_re24 = @relief_stats[5].text.to_f
			elsif row.text.include? mlbgame.home
				mlbgame.h_rp_xfip = @relief_stats[2].text.to_f
				mlbgame.h_rp_babip = @relief_stats[3].text.to_f
				mlbgame.h_rp_re24 = @relief_stats[5].text.to_f
			end
		end
		
		def_doc = Nokogiri::HTML(open("http://www.fangraphs.com/leaders.aspx?pos=all&stats=fld&lg=all&qual=0&type=c,40&season=2015&month=0&season1=2015&ind=0&team=0,ts&rost=0&age=0&filter=&players=0"))
		@def_table = def_doc.xpath('//*[@id="LeaderBoard1_dg1_ctl00"]/tbody')

		@def_table.css("tr").each do |row|
			@def_stats = row.css("td")
			if row.text.include? mlbgame.away
				mlbgame.a_uzr150 = @def_stats[2].text.to_f
			elsif row.text.include? mlbgame.home
				mlbgame.h_uzr150 = @def_stats[2].text.to_f
			end
		end
		
		standings_doc = Nokogiri::HTML(open("http://www.fangraphs.com/depthcharts.aspx?position=Standings"))
		@standings_table = standings_doc.xpath('//*[@id="content"]')
		@standings_table.css("tr").each do |row|
			if row.text.include? mlbgame.away
				mlbgame.a_rd = row.css("td")[5].text.to_f
			elsif row.text.include? mlbgame.home
				mlbgame.h_rd = row.css("td")[5].text.to_f
			end
		end
		
		
		# prediction algorithm 1: Hitting, Pitching, Fielding.
		# babip and baserunning factors *0.5, and wOBA/wRC calculated against league averages
		# SP babip *0.5, xfip and tera counted full. RP Stats and defense number scaled *0.75
		# take equal weight home hitting and away prevent, adjust by league avg rpg
		home_hitting = (0.5*((0.3-mlbgame.h_babip)*1000)) + ((mlbgame.h_woba-0.320)*1000) + (mlbgame.h_wrc-100) + (0.5*((mlbgame.h_bsr)*10))
		away_prevent = ((3.9-mlbgame.a_sp_xfip)*100) + (0.5*((mlbgame.a_sp_babip-0.300)*1000)) + ((4.3-mlbgame.a_sp_tera)*100) + (0.5*(0.75*((mlbgame.a_rp_babip-0.300)*1000))) + (0.75*((3.9-mlbgame.a_rp_xfip)*100)) + (0.75*((mlbgame.a_rp_re24)*10)) + (0.75*((mlbgame.a_uzr150)*10))
		
		away_hitting = (0.5*((0.3-mlbgame.a_babip)*1000)) + ((mlbgame.a_woba-0.320)*1000) + (mlbgame.a_wrc-100) + (0.5*((mlbgame.a_bsr)*10))
		home_prevent = ((3.9-mlbgame.h_sp_xfip)*100) + (0.5*((mlbgame.h_sp_babip-0.300)*1000)) + ((4.3-mlbgame.h_sp_tera)*100) + (0.5*(0.75*((mlbgame.h_rp_babip-0.300)*1000))) + (0.75*((3.9-mlbgame.h_rp_xfip)*100)) + (0.75*((mlbgame.h_rp_re24)*10)) + (0.75*((mlbgame.h_uzr150)*10))
		
		mlbgame.h_pred = ((home_hitting - away_prevent)/100) + 4.16 #leage avg runs per game
		mlbgame.a_pred = ((away_hitting - home_prevent)/100) + 4.16 #leage avg runs per game
		
		# prediction algorithm 2:
		# tera includes FIP so shouldn't use xfip? can still incorporate luck
		# ride the SP much heavier. A excellent SP tERA should have way more impact to helping your team win than relying on relievers. 
		# rp babip less weight, only use re24 - experiment
		# Use run differential as a predictive metric. Team with higher RD should get boost
		# home teams evenly matched win 54% of the time - 54-46 = 8% diff = 0.33 of 4.16 runs
		# defense slightly less factor
		
		home_hitting2 = (0.5*((0.3-mlbgame.h_babip)*1000)) + ((mlbgame.h_woba-0.320)*1000) + (mlbgame.h_wrc-100) + (0.5*((mlbgame.h_bsr)*10))
		away_prevent2 = (0.5*((mlbgame.a_sp_babip-0.300)*1000)) + ((4.3-mlbgame.a_sp_tera)*100) + (0.25*(0.75*((mlbgame.a_rp_babip-0.300)*1000))) + (0.75*((mlbgame.a_rp_re24)*10)) + (0.5*((mlbgame.a_uzr150)*10))
		
		away_hitting2 = (0.5*((0.3-mlbgame.a_babip)*1000)) + ((mlbgame.a_woba-0.320)*1000) + (mlbgame.a_wrc-100) + (0.5*((mlbgame.a_bsr)*10))
		home_prevent2 = (0.5*((mlbgame.h_sp_babip-0.300)*1000)) + ((4.3-mlbgame.h_sp_tera)*100) + (0.25*(0.75*((mlbgame.h_rp_babip-0.300)*1000))) + (0.75*((mlbgame.h_rp_re24)*10)) + (0.5*((mlbgame.h_uzr150)*10))
		
		#include run diff
		mlbgame.h_pred2 = ( (mlbgame.h_rd - mlbgame.a_rd )/100 ) + ((home_hitting2 - away_prevent2)/100) + 4.49 #leage avg rpg + hfa
		mlbgame.a_pred2 = ( (mlbgame.a_rd - mlbgame.h_rd )/100 ) + ((away_hitting2 - home_prevent2)/100) + 4.16 #league avg rpg
		
		
		if mlbgame.save
		else 
			render 'index'
		end
	end
	
	redirect_to mlbgames_path
	
end

	def edit
		@mlbgame = Mlbgame.find(params[:id])
		@stats = @mlbgame.attributes
	["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }
	end
	
	def scores
		require "open-uri"
		
		linkDate = Date.strptime(params[:date], '%Y-%m-%d').strftime('%Y%m%d')
		scores = Nokogiri::HTML(open("http://m.espn.go.com/wireless/scoreboard?date=#{linkDate}&groupId=9&wjb="))
		@games = scores.xpath("//*[substring(@id, 1, 4) = 'game']/div/a")
		@games.each do |game|
			if ((game['href'].include? "mlb") && ((game.text.include? "Final") || (game.text.include? "F/")))
				@mlbgame = Mlbgame.where("date = '#{params[:date]}' AND away = '#{Mlbgame.teamShort[game.text.split(" ")[0]]}'")
				if !@mlbgame[0].nil?
					@mlbgame[0].a_actual = game.text.split(" ")[1]
					@mlbgame[0].h_actual = game.text.split(" ")[3]
				
					if (@mlbgame[0].a_actual > @mlbgame[0].h_actual && @mlbgame[0].a_pred > @mlbgame[0].h_pred)
						@mlbgame[0].correct = 1
					elsif (@mlbgame[0].h_actual > @mlbgame[0].a_actual && @mlbgame[0].h_pred > @mlbgame[0].a_pred)
						@mlbgame[0].correct = 1
					else
						@mlbgame[0].correct = 0
					end
				
					if (@mlbgame[0].a_actual > @mlbgame[0].h_actual && @mlbgame[0].a_pred2 > @mlbgame[0].h_pred2)
						@mlbgame[0].correct2 = 1
					elsif (@mlbgame[0].h_actual > @mlbgame[0].a_actual && @mlbgame[0].h_pred2 > @mlbgame[0].a_pred2)
						@mlbgame[0].correct2 = 1
					else
						@mlbgame[0].correct2 = 0
					end
			
					if @mlbgame[0].save
					else 
						render 'index'
					end
				end
			end
		end
		
		redirect_to mlbgames_path
		
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
			if (@a_sp_stats[1].text.downcase.include? @mlbgame.a_name.split(" ", 2)[1].downcase) && ( @a_sp_stats[1].text[0] == @mlbgame.a_name[0])
				@mlbgame.a_sp_babip = @a_sp_stats[2].text.to_f
				@mlbgame.a_sp_xfip = @a_sp_stats[3].text.to_f
				@mlbgame.a_sp_tera = @a_sp_stats[4].text.to_f
			end
		end
		
		h_sp_doc = Nokogiri::HTML(open("http://www.fangraphs.com/leaders.aspx?pos=all&stats=pit&lg=all&qual=0&type=c,43,62,61&season=2015&month=3&season1=2015&ind=0&team=#{Mlbgame.teamID[@mlbgame.home]}&rost=0&age=0&filter=&players=0"))
	
		@h_sp_table = h_sp_doc.xpath('//*[@id="LeaderBoard1_dg1_ctl00"]/tbody')
		
		@h_sp_table.css("tr").each do |row|
			@h_sp_stats = row.css("td")
			if (@h_sp_stats[1].text.downcase.include? @mlbgame.h_name.split(" ", 2)[1].downcase) && (@h_sp_stats[1].text[0] == @mlbgame.h_name[0])
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
		
		standings_doc = Nokogiri::HTML(open("http://www.fangraphs.com/depthcharts.aspx?position=Standings"))
		@standings_table = standings_doc.xpath('//*[@id="content"]')
		@standings_table.css("tr").each do |row|
			if row.text.include? @mlbgame.away
				@mlbgame.a_rd = row.css("td")[5].text.to_f
			elsif row.text.include? @mlbgame.home
				@mlbgame.h_rd = row.css("td")[5].text.to_f
			end
		end
		
		
		# prediction algorithm 1: Hitting, Pitching, Fielding.
		# babip and baserunning factors *0.5, and wOBA/wRC calculated against league averages
		# SP babip *0.5, xfip and tera counted full. RP Stats and defense number scaled *0.75
		# take equal weight home hitting and away prevent, adjust by league avg rpg
		home_hitting = (0.5*((0.3-@mlbgame.h_babip)*1000)) + ((@mlbgame.h_woba-0.320)*1000) + (@mlbgame.h_wrc-100) + (0.5*((@mlbgame.h_bsr)*10))
		away_prevent = ((3.9-@mlbgame.a_sp_xfip)*100) + (0.5*((@mlbgame.a_sp_babip-0.300)*1000)) + ((4.3-@mlbgame.a_sp_tera)*100) + (0.5*(0.75*((@mlbgame.a_rp_babip-0.300)*1000))) + (0.75*((3.9-@mlbgame.a_rp_xfip)*100)) + (0.75*((@mlbgame.a_rp_re24)*10)) + (0.75*((@mlbgame.a_uzr150)*10))
		
		away_hitting = (0.5*((0.3-@mlbgame.a_babip)*1000)) + ((@mlbgame.a_woba-0.320)*1000) + (@mlbgame.a_wrc-100) + (0.5*((@mlbgame.a_bsr)*10))
		home_prevent = ((3.9-@mlbgame.h_sp_xfip)*100) + (0.5*((@mlbgame.h_sp_babip-0.300)*1000)) + ((4.3-@mlbgame.h_sp_tera)*100) + (0.5*(0.75*((@mlbgame.h_rp_babip-0.300)*1000))) + (0.75*((3.9-@mlbgame.h_rp_xfip)*100)) + (0.75*((@mlbgame.h_rp_re24)*10)) + (0.75*((@mlbgame.h_uzr150)*10))
		
		@mlbgame.h_pred = ((home_hitting - away_prevent)/100) + 4.16 #leage avg runs per game
		@mlbgame.a_pred = ((away_hitting - home_prevent)/100) + 4.16 #leage avg runs per game
		
		# prediction algorithm 2:
		# tera includes FIP so shouldn't use xfip? can still incorporate luck
		# ride the SP much heavier. A excellent SP tERA should have way more impact to helping your team win than relying on relievers. 
		# rp babip less weight, only use re24 - experiment
		# Use run differential as a predictive metric. Team with higher RD should get boost
		# home teams evenly matched win 54% of the time - 54-46 = 8% diff = 0.33 of 4.16 runs
		# defense slightly less factor
		
		home_hitting2 = (0.5*((0.3-@mlbgame.h_babip)*1000)) + ((@mlbgame.h_woba-0.320)*1000) + (@mlbgame.h_wrc-100) + (0.5*((@mlbgame.h_bsr)*10))
		away_prevent2 = (0.5*((@mlbgame.a_sp_babip-0.300)*1000)) + ((4.3-@mlbgame.a_sp_tera)*100) + (0.25*(0.75*((@mlbgame.a_rp_babip-0.300)*1000))) + (0.75*((@mlbgame.a_rp_re24)*10)) + (0.5*((@mlbgame.a_uzr150)*10))
		
		away_hitting2 = (0.5*((0.3-@mlbgame.a_babip)*1000)) + ((@mlbgame.a_woba-0.320)*1000) + (@mlbgame.a_wrc-100) + (0.5*((@mlbgame.a_bsr)*10))
		home_prevent2 = (0.5*((@mlbgame.h_sp_babip-0.300)*1000)) + ((4.3-@mlbgame.h_sp_tera)*100) + (0.25*(0.75*((@mlbgame.h_rp_babip-0.300)*1000))) + (0.75*((@mlbgame.h_rp_re24)*10)) + (0.5*((@mlbgame.h_uzr150)*10))
		
		#include run diff
		@mlbgame.h_pred2 = ( (@mlbgame.h_rd - @mlbgame.a_rd )/100 ) + ((home_hitting2 - away_prevent2)/100) + 4.49 #leage avg rpg + hfa
		@mlbgame.a_pred2 = ( (@mlbgame.a_rd - @mlbgame.h_rd )/100 ) + ((away_hitting2 - home_prevent2)/100) + 4.16 #league avg rpg
		
		
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
		  params.require(:mlbgame).permit(:home, :away, :date, :a_name, :h_name, :h_pred, :a_pred, :h_actual, :a_actual, :correct, :h_pred2, :a_pred2, :correct2)
		end
end
