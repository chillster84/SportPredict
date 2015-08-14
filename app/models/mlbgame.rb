class Mlbgame < ActiveRecord::Base
	validates :away, presence: true, length: { is: 3 }
	validates :home, presence: true, length: { is: 3 }
	validates :homeWPct, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
	validates :awayWPct, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }
end
