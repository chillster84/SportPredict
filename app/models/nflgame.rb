class Nflgame < ActiveRecord::Base

def self.teamShort
		{ 'GB' => 'Packers',
			'CHI' => 'Bears',
			'KC' => 'Chiefs',
			'HOU' => 'Texans',
			'CLE' => 'Browns',
			'NYJ' => 'Jets',
			'IND' => 'Colts',
			'BUF' => 'Bills',
			'MIA' => 'Dolphins',
			'WSH' => 'Redskins',
			'CAR' => 'Panthers',
			'JAX' => 'Jaguars',
			'SEA' => 'Seahawks',
			'STL' => 'Rams',
			'NO' => 'Saints',
			'ARI' => 'Cardinals',
			'DET' => 'Lions',
			'SD' => 'Chargers',
			'TEN' => 'Titans',
			'TB' => 'Buccaneers',
			'CIN' => 'Bengals',
			'OAK' => 'Raiders',
			'BAL' => 'Ravens',
			'DEN' => 'Broncos',
			'NYG' => 'Giants',
			'DAL' => 'Cowboys',
			'PIT' => 'Steelers',
			'NE' => 'Patriots',
			'PHI' => 'Eagles',
			'ATL' => 'Falcons',
			'MIN' => 'Vikings',
			'SF' => '49ers' }
	end

end
