#!/usr/bin/env bash
: ${1?"Version missing - usage: $0 x.y.z"}

#update build.gradle
line="\\\"version\\\":.*\\\".*\\\"/\\\"version\\\": \\\"$1\\\""

sed -i '.bak' "s/$line/g" plugin/package.json

#commit the version bump, tag, and push to private and public
git add plugin/package.json
