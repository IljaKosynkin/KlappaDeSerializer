Pod::Spec.new do |s|
  s.name         = "KlappaDeSerializer"
  s.version      = "2.1.1"
  s.summary      = "Lightweight library for JSON to object mapping using KVC and ObjC-Runtime"

  s.description  = <<-DESC
  Most of mappers require writing a lot of code that manually maps on object on another. 
  This library is supposed to do it autimatically, leaving to user possibility of defining own transformations. 
                   DESC

  s.homepage     = "https://github.com/IljaKosynkin/KlappaDeSerializer"

  s.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }

  s.author             = { "Ilia Kosynkin" => "ilja.kosynkin@gmail.com" }

  s.source       = { :git => "https://github.com/IljaKosynkin/KlappaDeSerializer.git", :tag => "v2.1.1" }

  s.source_files  = "KlappaDeSerializer", "KlappaDeSerializer/**/*.{h,m,c}"
  s.exclude_files = "Classes/Exclude"

  s.platform = :ios, '5.0'
end
