#!/usr/bin/env bash
: ${1?"Version missing - usage: $0 x.y.z"}

#update build.gradle
line="\\\"version\\\":.*\\\".*\\\"/\\\"version\\\": \\\"$1\\\""

sed -i '.bak' "s/$line/g" plugin/package.json
sed -i '.bak' "s/$line/g" Kits/Rokt/package.json

# update plugin.xml version attributes (matches X.Y.Z only, not the XML declaration's "1.0")
sed -i '.bak' "s/version=\"[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\"/version=\"$1\"/" plugin/plugin.xml
sed -i '.bak' "s/version=\"[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\"/version=\"$1\"/" Kits/Rokt/plugin.xml

#commit the version bump, tag, and push to private and public
git add plugin/package.json plugin/plugin.xml Kits/Rokt/package.json Kits/Rokt/plugin.xml
