class MlbgamesController < ApplicationController

	def index
		@mlbgames = Mlbgame.all
	end

	def show	
		@mlbgame = Mlbgame.find(params[:id])
	end	

	def new
  @mlbgame = Mlbgame.new
end

	def edit
		@mlbgame = Mlbgame.find(params[:id])
	end

	def create
		@mlbgame = Mlbgame.new(mlbgame_params)

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
		  params.require(:mlbgame).permit(:home, :away)
		end

end
