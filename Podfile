# For security reasons, please always keep the wordpress-mobile source first and the CDN second.
# For more info, see https://github.com/wordpress-mobile/cocoapods-specs#source-order-and-security-considerations
install! 'cocoapods', warn_for_multiple_pod_sources: false
source 'https://github.com/wordpress-mobile/cocoapods-specs.git'
source 'https://cdn.cocoapods.org/'

unless ['BUNDLE_BIN_PATH', 'BUNDLE_GEMFILE'].any? { |k| ENV.key?(k) }
  raise 'Please run CocoaPods via `bundle exec`'
end

inhibit_all_warnings!
use_frameworks!

app_ios_deployment_target = Gem::Version.new('13.0')

platform :ios, app_ios_deployment_target.version
workspace 'WordPress.xcworkspace'

## Pods shared between all the targets
## ===================================
##
def wordpress_shared
    pod 'WordPressShared', '~> 1.17.1'
    #pod 'WordPressShared', :git => 'https://github.com/wordpress-mobile/WordPress-iOS-Shared.git', :tag => ''
    #pod 'WordPressShared', :git => 'https://github.com/wordpress-mobile/WordPress-iOS-Shared.git', :branch => ''
    #pod 'WordPressShared', :git => 'https://github.com/wordpress-mobile/WordPress-iOS-Shared.git', :commit  => ''
    #pod 'WordPressShared', :path => '../WordPress-iOS-Shared'
end

def aztec
    ## When using a tagged version, feel free to comment out the WordPress-Aztec-iOS line below.
    ## When using a commit number (during development) you should provide the same commit number for both pods.
    ##
    #pod 'WordPress-Aztec-iOS', :git => 'https://github.com/wordpress-mobile/AztecEditor-iOS.git', :commit => ''
    #pod 'WordPress-Editor-iOS', :git => 'https://github.com/wordpress-mobile/AztecEditor-iOS.git', :commit => ''
    #pod 'WordPress-Editor-iOS', :git => 'https://github.com/wordpress-mobile/AztecEditor-iOS.git', :tag => ''
    #pod 'WordPress-Editor-iOS', :path => '../AztecEditor-iOS'
    pod 'WordPress-Editor-iOS', '~> 1.19.8'
end

def wordpress_ui
    pod 'WordPressUI', '~> 1.12.5'
    #pod 'WordPressUI', :git => 'https://github.com/wordpress-mobile/WordPressUI-iOS', :tag => ''
    #pod 'WordPressUI', :git => 'https://github.com/wordpress-mobile/WordPressUI-iOS', :branch => ''
    #pod 'WordPressUI', :git => 'https://github.com/wordpress-mobile/WordPressUI-iOS', :commit => ''
    #pod 'WordPressUI', :path => '../WordPressUI-iOS'
end

def wordpress_kit
    pod 'WordPressKit', '~> 4.50.0-beta.1'
    # pod 'WordPressKit', :git => 'https://github.com/wordpress-mobile/WordPressKit-iOS.git', :tag => ''
    # pod 'WordPressKit', :git => 'https://github.com/wordpress-mobile/WordPressKit-iOS.git', :branch => ''
    # pod 'WordPressKit', :git => 'https://github.com/wordpress-mobile/WordPressKit-iOS.git', :commit => ''
    # pod 'WordPressKit', :path => '../WordPressKit-iOS'
end

def kanvas
  pod 'Kanvas', '~> 1.2.7'
  #pod 'Kanvas', :git => 'https://github.com/tumblr/Kanvas-iOS.git', :tag => ''
  #pod 'Kanvas', :git => 'https://github.com/tumblr/Kanvas-iOS.git', :commit => ''
  #pod 'Kanvas', :path => '../Kanvas-iOS'
end

def shared_with_all_pods
    wordpress_shared
    pod 'CocoaLumberjack', '~> 3.0'
    pod 'NSObject-SafeExpectations', '~> 0.0.4'
end

def shared_with_networking_pods
    pod 'Alamofire', '4.8.0'
    pod 'Reachability', '3.2'

    wordpress_kit
end

def shared_test_pods
    pod 'OHHTTPStubs/Swift', '~> 9.1.0'
    pod 'OCMock', '~> 3.4.3'
end

def shared_with_extension_pods
    pod 'Gridicons', '~> 1.1.0'
    pod 'ZIPFoundation', '~> 0.9.8'
    pod 'Down', '~> 0.6.6'
end

def gutenberg(options)
    options[:git] = 'https://github.com/wordpress-mobile/gutenberg-mobile.git'
    options[:submodules] = true
    local_gutenberg = ENV['LOCAL_GUTENBERG']
    if local_gutenberg
      options = { :path => local_gutenberg.include?('/') ? local_gutenberg : '../gutenberg-mobile' }
    end
    pod 'Gutenberg', options
    pod 'RNTAztecView', options

    gutenberg_dependencies options
end

def gutenberg_dependencies(options)
    dependencies = [
        'FBLazyVector',
        'React',
        'ReactCommon',
        'RCTRequired',
        'RCTTypeSafety',
        'React-Core',
        'React-CoreModules',
        'React-RCTActionSheet',
        'React-RCTAnimation',
        'React-RCTBlob',
        'React-RCTImage',
        'React-RCTLinking',
        'React-RCTNetwork',
        'React-RCTSettings',
        'React-RCTText',
        'React-RCTVibration',
        'React-callinvoker',
        'React-cxxreact',
        'React-jsinspector',
        'React-jsi',
        'React-jsiexecutor',
        'React-logger',
        'React-perflogger',
        'React-runtimeexecutor',
        'boost',
        'Yoga',
        'RCT-Folly',
        'glog',
        'react-native-keyboard-aware-scroll-view',
        'react-native-safe-area',
        'react-native-safe-area-context',
        'react-native-video',
        'react-native-webview',
        'RNSVG',
        'react-native-slider',
        'BVLinearGradient',
        'react-native-get-random-values',
        'react-native-blur',
        'RNScreens',
        'RNReanimated',
        'RNGestureHandler',
        'RNCMaskedView',
        'RNCClipboard'
    ]
    if options[:path]
        podspec_prefix = options[:path]
    else
        tag_or_commit = options[:tag] || options[:commit]
        podspec_prefix = "https://raw.githubusercontent.com/wordpress-mobile/gutenberg-mobile/#{tag_or_commit}"
    end

    # FBReactNativeSpec needs special treatment because of react-native-codegen code generation
    pod 'FBReactNativeSpec', :podspec => "#{podspec_prefix}/third-party-podspecs/FBReactNativeSpec/FBReactNativeSpec.podspec.json"

    for pod_name in dependencies do
        pod pod_name, :podspec => "#{podspec_prefix}/third-party-podspecs/#{pod_name}.podspec.json"
    end
end

abstract_target 'Apps' do
    project 'WordPress/WordPress.xcodeproj'

    shared_with_all_pods
    shared_with_networking_pods
    shared_with_extension_pods

    ## Gutenberg (React Native)
    ## =====================
    ##
    gutenberg :commit => '11653e0b820bfa734f196b14305a1cdb86848bc8'

    ## Third party libraries
    ## =====================
    ##
    pod 'Charts', '~> 3.2.2'
    pod 'Gifu', '3.2.0'

    app_center_version = '~> 4.1'
    app_center_configurations = %w[Release-Internal Release-Alpha]
    pod 'AppCenter', app_center_version, configurations: app_center_configurations
    pod 'AppCenter/Distribute', app_center_version, configurations: app_center_configurations

    pod 'MRProgress', '0.8.3'
    pod 'Starscream', '3.0.6'
    pod 'SVProgressHUD', '2.2.5'
    pod 'ZendeskSupportSDK', '5.3.0'
    pod 'AlamofireImage', '3.5.2'
    pod 'AlamofireNetworkActivityIndicator', '~> 2.4'
    pod 'FSInteractiveMap', :git => 'https://github.com/wordpress-mobile/FSInteractiveMap.git', :tag => '0.2.0'
    pod 'JTAppleCalendar', '~> 8.0.2'
    pod 'AMScrollingNavbar', '5.6.0'
    pod 'CropViewController', '2.5.3'

    ## Automattic libraries
    ## ====================
    ##
    wordpress_kit
    wordpress_shared
    kanvas

    # Production

    pod 'Automattic-Tracks-iOS', '~> 0.11.1'
    # While in PR
    # pod 'Automattic-Tracks-iOS', :git => 'https://github.com/Automattic/Automattic-Tracks-iOS.git', :branch => ''
    # Local Development
    #pod 'Automattic-Tracks-iOS', :path => '~/Projects/Automattic-Tracks-iOS'

    pod 'NSURL+IDN', '~> 0.4'

    pod 'WPMediaPicker', '~> 1.8.3'
    # pod 'WPMediaPicker', :git => 'https://github.com/wordpress-mobile/MediaPicker-iOS.git', :tag => '1.7.0'
    ## while PR is in review:
    # pod 'WPMediaPicker', :git => 'https://github.com/wordpress-mobile/MediaPicker-iOS.git', :branch => ''
    # pod 'WPMediaPicker', :path => '../MediaPicker-iOS'

    pod 'Gridicons', '~> 1.1.0'

    pod 'WordPressAuthenticator', '~> 2.0.0'
    # pod 'WordPressAuthenticator', :git => 'https://github.com/wordpress-mobile/WordPressAuthenticator-iOS.git', :branch => ''
    # pod 'WordPressAuthenticator', :git => 'https://github.com/wordpress-mobile/WordPressAuthenticator-iOS.git', :commit => ''
    # pod 'WordPressAuthenticator', :path => '../WordPressAuthenticator-iOS'

    pod 'MediaEditor', '~> 1.2.1'
    # pod 'MediaEditor', :git => 'https://github.com/wordpress-mobile/MediaEditor-iOS.git', :commit => 'a4178ed9b0f3622faafb41dd12503e26c5523a32'
    # pod 'MediaEditor', :path => '../MediaEditor-iOS'

    aztec
    wordpress_ui

    ## WordPress App iOS
    ## =================
    ##
    target 'WordPress' do
        target 'WordPressTest' do
            inherit! :search_paths

            shared_test_pods
            pod 'Nimble', '~> 9.0.0'
        end
    end

    ## Jetpack App iOS
    ## ===============
    ##
    target 'Jetpack' do
    end
end

## Share Extension
## ===============
##
target 'WordPressShareExtension' do
    project 'WordPress/WordPress.xcodeproj'

    shared_with_extension_pods

    aztec
    shared_with_all_pods
    shared_with_networking_pods
    wordpress_ui
end


## DraftAction Extension
## =====================
##
target 'WordPressDraftActionExtension' do
    project 'WordPress/WordPress.xcodeproj'

    shared_with_extension_pods

    aztec
    shared_with_all_pods
    shared_with_networking_pods
    wordpress_ui
end


## Today Widget
## ============
##
target 'WordPressTodayWidget' do
    project 'WordPress/WordPress.xcodeproj'

    shared_with_all_pods
    shared_with_networking_pods

    wordpress_ui
end

## All Time Widget
## ============
##
target 'WordPressAllTimeWidget' do
    project 'WordPress/WordPress.xcodeproj'

    shared_with_all_pods
    shared_with_networking_pods

    wordpress_ui
end

## This Week Widget
## ============
##
target 'WordPressThisWeekWidget' do
    project 'WordPress/WordPress.xcodeproj'

    shared_with_all_pods
    shared_with_networking_pods

    wordpress_ui
end

## iOS 14 Today Widget
## ============
##
target 'WordPressStatsWidgets' do
    project 'WordPress/WordPress.xcodeproj'

    shared_with_all_pods
    shared_with_networking_pods

    wordpress_ui
end

## Intents
## ============
##
target 'WordPressIntents' do
    project 'WordPress/WordPress.xcodeproj'

    shared_with_all_pods
    shared_with_networking_pods

    wordpress_ui
end

## Notification Service Extension
## ==============================
##
target 'WordPressNotificationServiceExtension' do
    project 'WordPress/WordPress.xcodeproj'

    wordpress_kit
    wordpress_shared
    wordpress_ui
end


## Mocks
## ===================
##
def wordpress_mocks
  pod 'WordPressMocks', '~> 0.0.15'
  # pod 'WordPressMocks', :git => 'https://github.com/wordpress-mobile/WordPressMocks.git', :commit => ''
  # pod 'WordPressMocks', git: 'https://github.com/wordpress-mobile/WordPressMocks.git', branch: 'add-organization-id-to-me-sites'
  # pod 'WordPressMocks', :path => '../WordPressMocks'
end


## Screenshot Generation
## ===================
##
target 'WordPressScreenshotGeneration' do
    project 'WordPress/WordPress.xcodeproj'

    wordpress_mocks
end

## UI Tests
## ===================
##
target 'WordPressUITests' do
    project 'WordPress/WordPress.xcodeproj'

    wordpress_mocks
end

# Static Frameworks:
# ============
#
# Make all pods that are not shared across multiple targets into static frameworks by overriding the static_framework? function to return true
# Linking the shared frameworks statically would lead to duplicate symbols
# A future version of CocoaPods may make this easier to do. See https://github.com/CocoaPods/CocoaPods/issues/7428
shared_targets = ['WordPressFlux']
pre_install do |installer|
    static = []
    dynamic = []
    installer.pod_targets.each do |pod|
        # Statically linking Sentry results in a conflict with `NSDictionary.objectAtKeyPath`, but dynamically
        # linking it resolves this.
        if pod.name == 'Sentry'
          dynamic << pod
          next
        end

        # If this pod is a dependency of one of our shared targets, it must be linked dynamically
        if pod.target_definitions.any? { |t| shared_targets.include? t.name }
          dynamic << pod
          next
        end
        static << pod
		pod.instance_variable_set(:@build_type, Pod::BuildType.static_framework)
    end
    puts "Installing #{static.count} pods as static frameworks"
    puts "Installing #{dynamic.count} pods as dynamic frameworks"
end

post_install do |installer|
    project_root = File.dirname(__FILE__)

    ## Convert the 3rd-party license acknowledgements markdown into html for use in the app
    require 'commonmarker'

    acknowledgements = 'Acknowledgments'
    markdown = File.read("#{project_root}/Pods/Target Support Files/Pods-Apps-WordPress/Pods-Apps-WordPress-acknowledgements.markdown")
    rendered_html = CommonMarker.render_html(markdown, :DEFAULT)
    styled_html = "<head>
                     <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">
                     <style>
                       body {
                         font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', 'Helvetica Neue', sans-serif;
                         font-size: 16px;
                         color: #1a1a1a;
                         margin: 20px;
                       }
                      @media (prefers-color-scheme: dark) {
                       body {
                        background: #1a1a1a;
                        color: white;
                       }
                      }
                       pre {
                        white-space: pre-wrap;
                       }
                     </style>
                     <title>
                       #{acknowledgements}
                     </title>
                   </head>
                   <body>
                     #{rendered_html}
                   </body>"

      ## Remove the <h1>, since we've promoted it to <title>
      styled_html = styled_html.sub('<h1>Acknowledgements</h1>', '')

      ## The glog library's license contains a URL that does not wrap in the web view,
      ## leading to a large right-hand whitespace gutter.  Work around this by explicitly
      ## inserting a <br> in the HTML.  Use gsub juuust in case another one sneaks in later.
      styled_html = styled_html.gsub('p?hl=en#dR3YEbitojA/COPYING', 'p?hl=en#dR3YEbitojA/COPYING<br>')

    File.write("#{project_root}/Pods/Target Support Files/Pods-Apps-WordPress/acknowledgements.html", styled_html)

    # Let Pods targets inherit deployment target from the app
    # This solution is suggested here: https://github.com/CocoaPods/CocoaPods/issues/4859
    # =====================================
    #
    installer.pods_project.targets.each do |target|
      # Exclude RCT-Folly as it requires explicit deployment target https://git.io/JPb73
      if (target.name != 'RCT-Folly')
        target.build_configurations.each do |configuration|
          pod_ios_deployment_target = Gem::Version.new(configuration.build_settings['IPHONEOS_DEPLOYMENT_TARGET'])
          configuration.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET' if pod_ios_deployment_target <= app_ios_deployment_target
        end
      end
    end

    # Flag Alpha builds for Tracks
    # ============================
    installer.pods_project.targets.each do |target|
      next unless target.name == 'Automattic-Tracks-iOS'
      target.build_configurations.each do |config|
        if config.name == 'Release-Alpha' or config.name == 'Release-Internal'
          config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= ['$(inherited)', 'ALPHA=1']
        end
      end
    end
end
