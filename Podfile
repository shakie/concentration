platform :ios, '10.0'
use_frameworks!

def testing_pods
    pod 'Quick'
    pod 'Nimble'
end

target 'Concentration' do
    pod 'RealmSwift'
    pod 'SwiftyJSON'
    pod 'Moya/RxSwift'
    pod 'Moya-SwiftyJSONMapper/RxSwift'
    pod 'SVProgressHUD'
    pod 'RxSwift'
    pod 'RxCocoa'
end

target 'ConcentrationTests' do
    testing_pods
end

target 'ConcentrationUITests' do
    testing_pods
end
