require 'xcodeproj'

proj = Xcodeproj::Project.open('MParticleExample.xcodeproj')
target = proj.targets.find { |t| t.name == 'MParticleExample' }
group = proj.main_group.find_subpath('MParticleExample', false)

# Remove ObjC AppDelegate references from Xcode project
group.files.each do |f|
  if f.path && (f.path == 'AppDelegate.m' || f.path == 'AppDelegate.h')
    target.source_build_phase.files.each do |bf|
      bf.remove_from_project if bf.file_ref == f
    end
    f.remove_from_project
  end
end

# Add Swift AppDelegate
swift_ref = group.new_file('AppDelegate.swift')
target.source_build_phase.add_file_reference(swift_ref)

# Configure Swift build settings (no bridging header needed)
target.build_configurations.each do |config|
  config.build_settings['SWIFT_VERSION'] = '5.0'
  config.build_settings.delete('SWIFT_OBJC_BRIDGING_HEADER')
end

proj.save
puts 'Configured Xcode project with Swift AppDelegate'
