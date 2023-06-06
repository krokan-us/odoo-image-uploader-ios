# Uncomment the next line to define a global platform for your project
# platform :ios, '11.0'

target 'Odoo-iOS' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for Odoo-iOS
    pod 'Alamofire'
    pod 'CropViewController'
  target 'Odoo-iOSTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'Odoo-iOSUITests' do
    # Pods for testing
  end
end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 
'13.0'
               end
          end
   end
end
