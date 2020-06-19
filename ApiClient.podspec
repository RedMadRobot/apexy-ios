Pod::Spec.new do |s|
  s.name         = "ApiClient"
  s.version      = "1.0.0"
  s.summary      = "HTTP transport library"
  s.homepage     = "https://git.redmadrobot.com/foundation-ios/apiclient"
  s.license      = { :type => "MIT"}
  s.author       = { "Alexander Ignatiev" => "ai@redmadrobot.com" }
  s.source       = { :git => "https://git.redmadrobot.com/foundation-ios/apiclient.git", :tag => "#{s.version}" }

  s.ios.deployment_target = "10.0"
  s.tvos.deployment_target = "10.0"
  s.osx.deployment_target = "10.10"
  s.watchos.deployment_target = "4.0"

  s.swift_version = "5.0"
  s.source_files  = "Source/ApiClient/**/*.swift"
  s.dependency "Alamofire"
end
