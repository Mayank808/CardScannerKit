Pod::Spec.new do |spec|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  These will help people to find your library, and whilst it
  #  can feel like a chore to fill in it's definitely to your advantage. The
  #  summary should be tweet-length, and the description more in depth.
  #

  spec.name         = "CardScannerKit"
  spec.version      = "1.0.0"
  spec.summary      = "Adds a Portrait Card/Document Scanner Camera View to your application"

  spec.description  = "Uses Vision Kit and AVFoundations to build a ready to use document/card scanner view. Use the CardScannerView() with the ability to customize the button and card overlay of the view ontop of the default functionality. You also have access to ImagePermissionHandler() which will allow you to ask the user for permission to utilize thier devices camera. Insure that you have defined a Privacy - Camera Usage Description in your apps Info.plst before using the card scanner."

  spec.homepage     = "ADD GITHUB REPO"
  # spec.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"

  spec.license      = "MIT"
  # spec.license      = { :type => "MIT", :file => "FILE_LICENSE" }

  spec.author             = { "Mayank808" => "mayankmehra628@gmail.com" }
  # spec.authors            = { "Mayank808" => "mayankmehra628@gmail.com" }
  # spec.social_media_url   = "https://twitter.com/Mayank808"

  spec.platform     = :ios, "16.0"

  #  When using multiple platforms
  # spec.ios.deployment_target = "5.0"
  # spec.osx.deployment_target = "10.7"
  # spec.watchos.deployment_target = "2.0"
  # spec.tvos.deployment_target = "9.0"

  spec.source       = { :git => "GET GIT REPO HTTP LINK", :tag => spec.version.to_s }


  spec.source_files  = "CardScannerKit/**/*.{swift}"
  # spec.exclude_files = "Classes/Exclude"

  # spec.public_header_files = "Classes/**/*.h"

  # spec.resource  = "icon.png"
  # spec.resources = "Resources/*.png"

  # spec.preserve_paths = "FilesToSave", "MoreFilesToSave"

  spec.frameworks = "SwiftUI", "AVFoundation", "Vision"
  spec.swift_versions = "5.7"

  # spec.library   = "iconv"
  # spec.libraries = "iconv", "xml2"

  # spec.requires_arc = true

  # spec.xcconfig = { "HEADER_SEARCH_PATHS" => "$(SDKROOT)/usr/include/libxml2" }
  # spec.dependency "JSONKit", "~> 1.4"

end
