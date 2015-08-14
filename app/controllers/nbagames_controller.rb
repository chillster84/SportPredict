class NbagamesController < ApplicationController
	def index
		@nbagames = Nbagame.all
	end

	def show	
		@nbagame = Nbagame.find(params[:id])
		@stats = @nbagame.attributes
		["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }
	end	

	def new
  @nbagame = Nbagame.new
  @stats = @nbagame.attributes
		["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }
end

	def edit
		@nbagame = Nbagame.find(params[:id])
		@stats = @nbagame.attributes
		["id", "created_at", "updated_at"].each { |k| @stats.delete(k) }
	end

	def create
		@nbagame = Nbagame.new(nbagame_params)

		if @nbagame.save
			redirect_to @nbagame
		else 
			render 'new'
		end
	end
	
	def update
		@nbagame = Nbagame.find(params[:id])
		
		if @nbagame.update(nbagame_params)
			redirect_to @nbagame
		else
			render 'edit'
		end
	end

	def destroy
		@nbagame = Nbagame.find(params[:id])
		@nbagame.destroy
		
		redirect_to nbagames_path
	end

	private
		def nbagame_params
		  params.require(:nbagame).permit(:home, :away, :homeWPct, :awayWPct, :homePPG, :awayPPG)
		end
end
