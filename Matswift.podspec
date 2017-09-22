#
# Be sure to run `pod lib lint Matswift.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Matswift'
  s.version          = '0.1.2'
  s.summary          = 'Matrix calculations in Swift'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/jknthn/Matswift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'jknthn' => 'jeremi.kaczmarczyk@gmail.com' }
  s.source           = { :git => 'https://github.com/jknthn/Matswift.git', :tag => '0.1.2' }
  # s.social_media_url = 'https://twitter.com/_jeerr'

  s.ios.deployment_target = '10.3'
  s.osx.deployment_target = '10.7'

  s.source_files = 'Matswift/Classes/*'
  
  # s.resource_bundles = {
  #   'Matswift' => ['Matswift/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
