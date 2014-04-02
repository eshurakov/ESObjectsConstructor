Pod::Spec.new do |s|
  s.name     = 'ESObjectsConstructor'
  s.version  = '0.7'
  s.license  = 'MIT'
  s.summary  = 'Objects constructor'
  s.homepage = 'https://github.com/eshurakov/ESObjectsConstructor'
  s.author   = { 'Evgeny Shurakov' => 'github@shurakov.name' }
  s.source   = { :git => 'https://github.com/eshurakov/ESObjectsConstructor.git' }
  s.source_files = 'ESObjectsConstructor/Classes/**/*.{h,m}'
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
end
