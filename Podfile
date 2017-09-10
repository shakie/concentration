platform :ios, '10.0'

target 'Concentration' do
    use_frameworks!
    
    pod 'RealmSwift'
    pod 'SwiftyJSON'
    pod 'Moya/RxSwift'
    pod 'Moya-SwiftyJSONMapper/RxSwift'
    pod 'SVProgressHUD'
    pod 'RxSwift'
    pod 'RxCocoa'
    pod 'Kingfisher', '~> 3.0'
    
    def testing_pods
        pod 'RxBlocking'
        pod 'RxTest'
        pod 'RxNimble'
        pod 'Quick'
        pod 'Nimble'
    end

    target 'ConcentrationTests' do
        inherit! :search_paths
        
        testing_pods
    end

    target 'ConcentrationUITests' do
        inherit! :search_paths
        
        testing_pods
    end

    post_install do |installer|
        installer.pods_project.targets.each do |target|
            if target.name == ‘RxSwift’
                target.build_configurations.each do |config|
                    if config.name == ‘Debug’
                        config.build_settings[‘OTHER_SWIFT_FLAGS’] ||= [‘-D’, ‘TRACE_RESOURCES’]
                    end
                end
            end
        end
    end

end
