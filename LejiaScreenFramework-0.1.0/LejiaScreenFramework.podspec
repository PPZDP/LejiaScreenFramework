Pod::Spec.new do |s|
  s.name = "LejiaScreenFramework"
  s.version = "0.1.0"
  s.summary = "A short description of LejiaScreenFramework."
  s.license = {"type"=>"MIT", "file"=>"LICENSE"}
  s.authors = {"sawrysc@163.com"=>"jiarui.li@carrobot.com"}
  s.homepage = "https://github.com/PPZDP/LejiaScreenFramework"
  s.description = "TODO: Add long description of the pod here."
  s.source = { :path => '.' }

  s.ios.deployment_target    = '9.0'
  s.ios.vendored_framework   = 'ios/LejiaScreenFramework.framework'
end
