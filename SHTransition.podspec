Pod::Spec.new do |s|
  s.name         = "SHTransition"
  s.version      = "1.0.0"
  s.summary      = "VC Transition Framework"
  s.description  = "VC Transition Framework"

  s.homepage     = "https://github.com/iamshezad/SHTransition.git"

  s.license      = "MIT"

  s.author             = { "iamShezad" => "shezadahamed95@gmail.com" }

  s.source       = { :git => "https://github.com/iamshezad/SHTransition.git", :tag => "1.0.0" }

  s.source_files  = "SHTransition/*.{swift,h,m}",

  s.ios.deployment_target = '9.0'
 
end