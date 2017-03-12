# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'uMAPit' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  pod 'Alamofire', '~> 4.3.0'
  pod 'RealmSwift'
  pod 'SwiftyJSON'
  pod 'Kingfisher', '~> 3.0'
  pod 'ImageSlideshow', '~> 1.0.0'
  pod 'ImageSlideshow/Kingfisher'
  pod 'GoogleMaps'
  pod 'GooglePlaces'
  pod 'SlackTextViewController'


  # Pods for uMAPit

  target 'uMAPitTests' do
    inherit! :search_paths
    # Pods for testing
    pod 'RealmSwift'
  end

  target 'uMAPitUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end
post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
