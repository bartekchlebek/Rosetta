Pod::Spec.new do |spec|
  spec.name             = 'Rosetta'
  spec.version          = '0.0.2'
  spec.summary          = 'Swift JSON mapper'
  spec.homepage         = 'https://github.com/bartekchlebek/Rosetta'
  spec.license          = { :type => 'MIT' }
  spec.author           = { 'Bartek Chlebek' => 'bartek.public@gmail.com' }
  spec.social_media_url = 'http://twitter.com/bartekchlebek'
  spec.source           = { :git => 'https://github.com/bartekchlebek/Rosetta.git', :tag => "#{spec.version}" }
  spec.source_files     = 'Rosetta/*.swift'
  spec.requires_arc     = true
end
