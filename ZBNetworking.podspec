Pod::Spec.new do |s|
  s.name         = "ZBNetworking"
  s.version      = "0.0.1"
  s.summary      = "AFNetworking+ZBPromise."
  s.description  = <<-DESC
                  This is a Network framework of AFNetworking+ZBPromise.
                   DESC
  s.homepage     = "https://github.com/githubzb/ZBNetworking"
#  s.license      = "MIT (example)"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "dr.box" => "1126976340@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://github.com/githubzb/ZBNetworking.git", :tag => "#{s.version}" }
  s.source_files  = "#{s.name}/Resource/**/*.{h,m}"
  s.requires_arc = true
  s.dependency "zbpromise", "~> 0.0.1"
  s.dependency "AFNetworking", "~> 3.2.1"
  s.dependency "Reachability", "~> 3.2"

end
