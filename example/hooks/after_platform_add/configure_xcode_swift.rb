require 'xcodeproj'

proj = Xcodeproj::Project.open('MParticleExample.xcodeproj')
target = proj.targets.find { |t| t.name == 'MParticleExample' }
group = proj.main_group.find_subpath('MParticleExample', false)

swift_ref = group.new_file('RoktPaymentSetup.swift')
target.source_build_phase.add_file_reference(swift_ref)

target.build_configurations.each do |config|
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['SWIFT_OBJC_BRIDGING_HEADER'] = 'MParticleExample/MParticleExample-Bridging-Header.h'
end

proj.save
puts 'Configured Xcode project for Swift/Shoppable Ads'
