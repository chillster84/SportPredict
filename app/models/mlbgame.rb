class Mlbgame < ActiveRecord::Base
	validates :away, presence: true, length: { is: 3 }
	validates :home, presence: true, length: { is: 3 }
end
