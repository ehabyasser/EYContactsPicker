Pod::Spec.new do |spec|

spec.name         = "EYContactsPicker"
spec.version      = "1.0.0"
spec.summary      = "EYContactsPicker is a modern, highly customisable contacts picker with search and multi-selection options."

spec.description  = <<-DESC
A modern, highly customisable contact picker with multi-selection options that closely resembles the behaviour of the ContactsUI's CNContactPickerViewController.
DESC

spec.homepage     = "https://github.com/ehabyasser/EYContactsPicker"

spec.license      = { :type => "MIT", :file => "LICENSE" }

spec.author             = "ehabyasser"
spec.social_media_url   = "https://x.com/ehab12165518?s=11"

spec.swift_version = '5.0'
spec.platform     = :ios, "13.0"

spec.source       = { :git => "https://github.com/ehabyasser/EYContactsPicker.git", :tag => "#{spec.version}" }

spec.source_files  = "Sources/**/*.swift"

spec.dependency 'SnapKit', '~> 5.6.0'

spec.module_name = 'EYContactsPicker'

spec.frameworks = "Contacts", "ContactsUI"

spec.ios.deployment_target = '12.0'

end
