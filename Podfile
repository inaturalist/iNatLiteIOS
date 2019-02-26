platform :ios, '10.3'
use_frameworks!

target 'iNatLite' do
  pod 'Alamofire', '4.8.1'
  pod 'Imaginary', '4.2.0'
  pod 'JSONWebToken', '2.2.0'
  pod 'UIImageViewAlignedSwift', '0.5.0'
  pod 'FontAwesomeKit', '2.2.1'
  pod 'Charts', '3.2.2'
  pod 'Cache', '5.2.0'
  pod 'RealmSwift', '3.13.1'
  pod 'CRToast', '0.0.9'
  pod 'Toast-Swift', '4.0.1'
  pod 'Gallery', '2.2.0'
  pod 'PKHUD', '~> 5.0'
  pod 'CropViewController', '2.4.0'
  pod 'moa', '10.0.0'
  pod 'Auk', '9.0.0'
end

post_install do |installer|
    
    installer.pods_project.targets.each do |target|
        
        if target.name == 'JSONWebToken'
            system("rm -rf Pods/JSONWebToken/CommonCrypto")
        end
        
    end
    
end
