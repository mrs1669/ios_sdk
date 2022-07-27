Pod::Spec.new do |s|
  s.name                   = "AdjustTestOptionsLibrary"
  s.version                = "1.0.0"
  s.summary                = "This is the iOS Adjust Test Options Library."
  s.homepage               = "https://github.com/adjust/ios_sdk"
  s.license                = { :type => 'MIT', :file => 'MIT-LICENSE' }
  s.author                 = { "Adjust GmbH" => "sdk@adjust.com" }
  s.source                 = { :git => "https://github.com/adjust/ios_sdk.git", :tag => "v4.30.0" }
  s.ios.deployment_target  = '9.0'
  s.tvos.deployment_target = '9.0'
  s.requires_arc           = true
  s.pod_target_xcconfig    = { 'BITCODE_GENERATION_MODE' => 'bitcode' }
  s.source_files           = 'AdjustTestOptionsLibrary/**/*.{h,m}'

end
