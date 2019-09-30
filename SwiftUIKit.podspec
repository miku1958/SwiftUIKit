Pod::Spec.new do |spec|

  spec.name         = "SwiftUIKit"
  spec.version      = "1.0.0"
  spec.summary      = "A SwfitUI style UIKit"

  spec.description  = <<-DESC
  A SwfitUI style UIKit tool
                   DESC

  spec.homepage     = "https://github.com/miku1958/SwiftUIKit"

  spec.license      = "Mozilla"

  spec.author       = { "miku1958" => "v.v1958@qq.com" }

  spec.platform     = :ios, "9.0"

  spec.source       = { :git => "https://github.com/miku1958/SwiftUIKit.git", :tag => "#{spec.version}" }

  spec.source_files  = "Sources/**/*.{swift}", "SwiftUIKit/SwiftUIKit.h"

  spec.requires_arc = true

  spec.swift_version = '5.0'
end
