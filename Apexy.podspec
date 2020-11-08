Pod::Spec.new do |s|
  s.name         = "Apexy"
  s.version      = "1.1.0"
  s.summary      = "HTTP transport library"
  s.homepage     = "https://github.com/RedMadRobot/apexy-ios"
  s.license      = { :type => "MIT"}
  s.author       = { "Alexander Ignatiev" => "ai@redmadrobot.com" }
  s.source       = { :git => "https://github.com/RedMadRobot/apexy-ios.git", :tag => "#{s.version}" }

  s.ios.deployment_target = "11.0"
  s.tvos.deployment_target = "11.0"
  s.osx.deployment_target = "10.13"
  s.watchos.deployment_target = "4.0"

  s.swift_version = "5.3"

  s.subspec 'Core' do |sp|
    sp.source_files = "Sources/Apexy/*.swift"
  end

  s.subspec 'Alamofire' do |sp|
    sp.source_files = "Sources/Apexy_Alamofire/*.swift"
    sp.dependency "Apexy/Core"
    sp.dependency "Alamofire", '~>5.0'
  end

  s.subspec 'URLSession' do |sp|
    sp.source_files = "Sources/Apexy_URLSession/*.swift"
    sp.dependency "Apexy/Core"
  end

  s.subspec 'RxSwift' do |sp|
    sp.source_files = "Sources/Apexy_RxSwift/*.swift"
    sp.dependency "Apexy/Core"
    sp.dependency "RxSwift"
  end

  s.default_subspecs = ["Alamofire"]

end