class Nhlgame < ActiveRecord::Base
	validates :away, presence: true, length: { is: 3 }
	validates :home, presence: true, length: { is: 3 }
	validates :homeW, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 82 }
	validates :homeL, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 82 }
	validates :homeOTL, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 82 }
	validates :awayW, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 82 }
	validates :awayL, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 82 }
	validates :awayOTL, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 82 }
	validates :homeGF, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000 }
	validates :homeGA, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000 }
	validates :awayGF, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000 }
	validates :awayGA, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1000 }
end
