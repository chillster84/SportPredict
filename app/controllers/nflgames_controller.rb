class NflgamesController < ApplicationController

	def index
		@nflgames = Nflgame.all
		@correct = ( (@nflgames.sum(:correct).to_f) / (@nflgames.where("correct IS NOT NULL").count.to_f) * 100 ).round
	end

	def show	
		@nflgame = Nflgame.find(params[:id])
		@stats = @nflgame.attributes
		["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }
	end	

	def new
	
	require "open-uri"
  @nflgames = []
  #@stats = @nflgame.attributes
	#["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }	
	schedule = Nokogiri::HTML(open("http://m.espn.go.com/wireless/scoreboard?wjb"))
	@games = schedule.xpath("//*[substring(@id, 1, 4) = 'game']/div/a")
	@games.each do |game|
		if ((game['href'].include? "nfl") && (game.text.include? "PM"))
			@nflgame = Nflgame.new
			@nflgame.date = Time.now.strftime("%d/%m/%Y")
			@nflgame.away = Nflgame.teamShort[game.text.split(" ")[0]]
			@nflgame.home = Nflgame.teamShort[game.text.partition('at ').last.split(" ")[0]]
			@nflgames << @nflgame
		end
	end 
	
	#have all the games. Get data and save each one
	@nflgames.each do |nflgame|
		srsoffense_doc = Nokogiri::HTML(open("http://www.pro-football-reference.com/years/2014/"))
	
		@afc_standings_table = srsoffense_doc.xpath('//*[@id="AFC"]/tbody')
		@nfc_standings_table = srsoffense_doc.xpath('//*[@id="NFC"]/tbody')

		#get the SRS values
		@afc_standings_table.css("tr").each do |row|
			@afc_standings_stats = row.css("td")
			if row.text.include? nflgame.away
				nflgame.a_SRS = @afc_standings_stats[10].text.to_f
			elsif row.text.include? nflgame.home
				nflgame.h_SRS = @afc_standings_stats[10].text.to_f
			end
		end
		
		@nfc_standings_table.css("tr").each do |row|
			@nfc_standings_stats = row.css("td")
			if row.text.include? nflgame.away
				nflgame.a_SRS = @nfc_standings_stats[10].text.to_f
			elsif row.text.include? nflgame.home
				nflgame.h_SRS = @nfc_standings_stats[10].text.to_f
			end
		end
		
		#get TO, PYA, RYA from the offense table
		
		@offense_table = srsoffense_doc.xpath('//*[@id="team_stats"]/tbody')
		
		@offense_table.css("tr").each do |row|
			@offense_stats = row.css("td")
			if row.text.include? nflgame.away
				nflgame.a_PYA = @offense_stats[16].text.to_f
				nflgame.a_RYA = @offense_stats[21].text.to_f
				nflgame.a_TO = @offense_stats[24].text.to_f
			elsif row.text.include? nflgame.home
				nflgame.h_PYA = @offense_stats[16].text.to_f
				nflgame.h_RYA = @offense_stats[21].text.to_f
				nflgame.h_TO = @offense_stats[24].text.to_f
			end
		end
		
		def_doc = Nokogiri::HTML(open("http://www.pro-football-reference.com/years/2014/opp.htm"))
		@def_table = def_doc.xpath('//*[@id="team_stats"]/tbody')
		@def_table.css("tr").each do |row|
			@def_stats = row.css("td")
			if row.text.include? nflgame.away
				nflgame.a_DPYA = @def_stats[16].text.to_f
				nflgame.a_DRYA = @def_stats[21].text.to_f
			elsif row.text.include? nflgame.home
				nflgame.h_DPYA = @def_stats[16].text.to_f
				nflgame.h_DRYA = @def_stats[21].text.to_f
			end
		end
		
		#prediction algorithm 1: SRS (MOV + SOS), PYA , RYA, a little TO (0.3 factor)
		#22.6 is league avg ppg - scale off this. SRS can be used as a points marker
		#TO not sustainable so lower than avg can say a bit about being more susceptible to TO in future
		#passing league so PYA numbers weighted heavier
		#3 runs for home team +/- 1.5
		nflgame.a_pred = 22.6 + nflgame.a_SRS + 0.3*(nflgame.a_TO-13) + 8*(nflgame.a_PYA-6.4) + 6*(nflgame.a_RYA-4.2) - 8*(6.4-nflgame.h_DPYA) - 6*(4.2-nflgame.h_DRYA) - 1.5
		
		nflgame.h_pred = 22.6 + nflgame.h_SRS + 0.3*(nflgame.h_TO-13) + 8*(nflgame.h_PYA-6.4) + 6*(nflgame.h_RYA-4.2) - 8*(6.4-nflgame.a_DPYA) - 6*(4.2-nflgame.a_DRYA) + 1.5
		
		if nflgame.save
		else 
			render 'index'
		end
	end
	
	redirect_to nflgames_path
	
end

	def scores
		require "open-uri"
		
		linkDate = Date.strptime(params[:date], '%Y-%m-%d').strftime('%Y%m%d')
		scores = Nokogiri::HTML(open("http://m.espn.go.com/wireless/scoreboard?date=#{linkDate}&groupId=9&wjb="))
		@games = scores.xpath("//*[substring(@id, 1, 4) = 'game']/div/a")
		@games.each do |game|
			if ((game['href'].include? "nfl") && ((game.text.include? "Final") || (game.text.include? "F/")))
				@nflgame = Nflgame.where("date = '#{params[:date]}' AND away = '#{Nflgame.teamShort[game.text.split(" ")[0]]}'")
				if !@nflgame[0].nil?
					@nflgame[0].a_actual = game.text.split(" ")[1]
					@nflgame[0].h_actual = game.text.split(" ")[3]
				
					if (@nflgame[0].a_actual > @nflgame[0].h_actual && @nflgame[0].a_pred > @nflgame[0].h_pred)
						@nflgame[0].correct = 1
					elsif (@nflgame[0].h_actual > @nflgame[0].a_actual && @nflgame[0].h_pred > @nflgame[0].a_pred)
						@nflgame[0].correct = 1
					else
						@nflgame[0].correct = 0
					end
				
					if @nflgame[0].save
					else 
						render 'index'
					end
				end
			end
		end
		
		redirect_to nflgames_path
		
	end

	def edit
		@nflgame = Nflgame.find(params[:id])
		@stats = @nflgame.attributes
		["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }
	end

	def create
		@nflgame = Nflgame.new(nflgame_params)

		if @nflgame.save
			redirect_to @nflgame
		else 
			render 'new'
		end
	end
	
	def update
		@nflgame = Nflgame.find(params[:id])
		
		if @nflgame.update(nflgame_params)
			redirect_to @nflgame
		else
			render 'edit'
		end
	end

	def destroy
		@nflgame = Nflgame.find(params[:id])
		@nflgame.destroy
		
		redirect_to nflgames_path
	end

	private
		def nflgame_params
		  params.require(:nflgame).permit(:home, :away)
		end

end
