Pod::Spec.new do |s|
  s.name         = "Apexy"
  s.version      = "1.0.0"
  s.summary      = "HTTP transport library"
  s.homepage     = "https://github.com/RedMadRobot/apexy-ios"
  s.license      = { :type => "MIT"}
  s.author       = { "Alexander Ignatiev" => "ai@redmadrobot.com" }
  s.source       = { :git => "https://github.com/RedMadRobot/apexy-ios.git", :tag => "#{s.version}" }

  s.ios.deployment_target = "10.0"
  s.tvos.deployment_target = "10.0"
  s.osx.deployment_target = "10.12"
  s.watchos.deployment_target = "4.0"

  s.swift_version = "5.2"
  
  s.dependency "Alamofire", '~>5.0'

  s.subspec 'Core' do |sp|
    sp.source_files = "Sources/Apexy/*.swift"
  end

  s.subspec 'RxSwift' do |sp|
    sp.source_files = "Sources/ApexyRxSwift/*.swift"
    sp.dependency "RxSwift"
    sp.dependency "Apexy/Core"
  end

  s.default_subspecs = "Core"

end