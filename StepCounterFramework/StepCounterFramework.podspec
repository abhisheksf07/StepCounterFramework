Pod::Spec.new do |spec|
  spec.name         = "StepCounterFramework"
  spec.version      = "1.0.4"
  spec.summary      = "This is a step counter framework from health app"
  spec.description  = "By this faramework you can ask for user consent to access Health app data and read/write steps from there to own app"
  spec.homepage     = "https://github.com/abhisheksf07/StepCounterFramework"
  spec.license      = "MIT"
  spec.author       = { "abhishek singla" => "abhishek.singla@sourcefuse.com" }
  spec.platform     = :ios, "12.4"
  spec.source       = { :git => "https://github.com/abhisheksf07/StepCounterFramework.git", :tag => "1.0.4" }
  spec.source_files = "StepCounterFramework/StepCounterFramework/*.swift"
  spec.framework  = "HealthKit"
  spec.pod_target_xcconfig = { 'SWIFT_VERSION' => '4.0' }
  spec.swift_version = '4.0'

end
