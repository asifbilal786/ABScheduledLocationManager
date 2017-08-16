Pod::Spec.new do |s|

# ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.name             = 'ABScheduledLocationManager'
s.version          = '0.1'
s.summary          = 'This is location manager which can be used getting locations with specific interval of time.'
s.description      = <<-DESC
A utility control to fetch locations with a specified interval of time even in the background.
DESC

s.homepage         = 'https://github.com/asifbilal786/ABScheduledLocationManager'
s.frameworks       = 'UIKit'
s.requires_arc     = true


# ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.license          = { :type => 'MIT', :file => 'LICENSE' }



# ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.author           = { 'Asif Bilal' => 'asifbilal786@gmail.com' }


# ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.platform     = :ios, "8.0"


# ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
s.source           = { :git => 'https://github.com/asifbilal786/ABScheduledLocationManager.git', :tag => s.version }
s.social_media_url = 'https://twitter.com/asifbilal786'

s.default_subspec  = 'Source'

s.subspec 'Source' do |sp|

sp.source_files = 'Pod', 'ABScheduledLocationManager/Source/*.swift'
end


end
