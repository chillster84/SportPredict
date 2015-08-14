class NflgamesController < ApplicationController

	def index
		@nflgames = Nflgame.all
	end

	def show	
		@nflgame = Nflgame.find(params[:id])
		@stats = @nflgame.attributes
		["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }
	end	

	def new
  @nflgame = Nflgame.new
  @stats = @nflgame.attributes
		["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }
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
		  params.require(:nflgame).permit(:home, :away, :homeWPct, :awayWPct)
		end

end
