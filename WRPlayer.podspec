#
# Be sure to run `pod lib lint WRPlayer.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WRPlayer'
  s.version          = '0.1.0'
  s.summary          = '多媒体播放器'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/God_Fighter/WRPlayer'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'God_Fighter' => 'xianghui_ios@163.com' }
  s.source           = { :git => 'https://github.com/God_Fighter/WRPlayer.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'WRPlayer/Classes/**/*'
  
  s.resources = "WRPlayer/Assets/*.xcassets"
#   s.resources = {
#     'WRPlayer' => ['WRPlayer/Assets/*.xcassets']
#   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'AVFoundation', 'CoreServices'
  # s.dependency 'AFNetworking', '~> 2.3'
end
