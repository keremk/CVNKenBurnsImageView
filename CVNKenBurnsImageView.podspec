Pod::Spec.new do |s|
  s.name         = "CVNKenBurnsImageView"
  s.version      = "0.0.1"
  s.summary      = "A short description of CVNKenBurnImageView."

  s.description  = <<-DESC
                   A longer description of CVNKenBurnImageView in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "http://EXAMPLE/CVNKenBurnImageView"
  # s.screenshots  = "www.example.com/screenshots_1.gif", "www.example.com/screenshots_2.gif"
  s.license      = "MIT (example)"
  s.author             = { "Kerem Karatal" => "kkaratal@yahoo.com" }
  s.social_media_url   = "http://twitter.com/keremk"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "http://github.com/keremk/CVNKenBurnsImageView.git", :tag => "0.0.1" }


  s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.exclude_files = "Classes/Exclude"

  # s.public_header_files = "Classes/**/*.h"

  # s.resource  = "icon.png"
  # s.resources = "Resources/*.png"

  # s.preserve_paths = "FilesToSave", "MoreFilesToSave"

  # s.framework  = "SomeFramework"
  # s.frameworks = "SomeFramework", "AnotherFramework"

  # s.library   = "iconv"
  # s.libraries = "iconv", "xml2"

  s.requires_arc = true

  s.dependency "AFNetworking", "~> 2.2"
end
