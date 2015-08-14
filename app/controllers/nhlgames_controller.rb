class NhlgamesController < ApplicationController
	def index
		@nhlgames = Nhlgame.all
	end

	def show	
		@nhlgame = Nhlgame.find(params[:id])
	end	

	def new
  @nhlgame = Nhlgame.new
end

	def edit
		@nhlgame = Nhlgame.find(params[:id])
	end

	def create
		@nhlgame = Nhlgame.new(nhlgame_params)

		if @nhlgame.save
			redirect_to @nhlgame
		else 
			render 'new'
		end
	end
	
	def update
		@nhlgame = Nhlgame.find(params[:id])
		
		if @nhlgame.update(nhlgame_params)
			redirect_to @nhlgame
		else
			render 'edit'
		end
	end

	def destroy
		@nhlgame = Nhlgame.find(params[:id])
		@nhlgame.destroy
		
		redirect_to nhlgames_path
	end

	private
		def nhlgame_params
		  params.require(:nhlgame).permit(:home, :away, :homeW, :homeL, :homeOTL, :awayW, :awayL, :awayOTL, :homeGF, :homeGA, :awayGF, :awayGA)
		end
end
