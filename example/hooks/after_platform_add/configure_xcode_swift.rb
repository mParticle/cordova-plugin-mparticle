require 'xcodeproj'

proj = Xcodeproj::Project.open('MParticleExample.xcodeproj')
target = proj.targets.find { |t| t.name == 'MParticleExample' }
group = proj.main_group.find_subpath('MParticleExample', false)

# Idempotent: re-running this hook must not add a second reference to the same
# Swift file, which would create duplicate compile sources and break the build.
swift_ref = group.files.find { |f| f.display_name == 'RoktPaymentSetup.swift' } ||
            group.new_file('RoktPaymentSetup.swift')
unless target.source_build_phase.files_references.include?(swift_ref)
  target.source_build_phase.add_file_reference(swift_ref)
end

target.build_configurations.each do |config|
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings['SWIFT_OBJC_BRIDGING_HEADER'] = 'MParticleExample/MParticleExample-Bridging-Header.h'
end

proj.save
puts 'Configured Xcode project for Swift/Shoppable Ads'
