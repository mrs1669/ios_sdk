Pod::Spec.new do |s|
  s.name                   = "Adjust"
  s.version                = "5.0.0"
  s.summary                = "This is the iOS SDK of adjust. You can read more about it at http://adjust.com."
  s.homepage               = "https://github.com/adjust/ios_sdk"
  s.license                = { :type => 'MIT', :file => 'MIT-LICENSE' }
  s.author                 = { "Adjust GmbH" => "sdk@adjust.com" }
  s.source                 = { :git => "https://github.com/adjust/ios_sdk.git", :tag => "v4.30.0" }
  s.ios.deployment_target  = '9.0'
  s.tvos.deployment_target = '9.0'
  s.framework              = 'SystemConfiguration'
  s.ios.weak_framework     = 'AdSupport', 'iAd', 'CoreTelephony'
  s.tvos.weak_framework    = 'AdSupport'
  s.requires_arc           = true
  s.default_subspec        = 'Core'
  s.pod_target_xcconfig    = { 'BITCODE_GENERATION_MODE' => 'bitcode' }
  s.subspec 'Core' do |co|
    co.source_files        = 'Adjust/**/*.{h,m}'
  end
end
