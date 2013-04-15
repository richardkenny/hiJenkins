#!/usr/bin/env bash

# Build local variables
#XcodeAppName=helloJenkins-ios
#BUILD_NUMBER=1
#WORKSPACE=/Users/amirxk0/.jenkins/jobs/jenkinstest-ios
#Config=AutobuildRelease
#Target=helloJenkins-ios
#Scheme="Hello Jenkins"

# Set the DEVELOPER_DIR for xcode for project
export DEVELOPER_DIR=/Applications/${XcodeAppName}.app/Contents/Developer

# move into source directory
cd "Hello Jenkins"

# Clean the project
xcodebuild clean

# set the project/target version number and build number to the current (jenkins) build number index
agvtool new-version -all ${BUILD_NUMBER}

# Build project
xcodebuild -target ${Target} -scheme ${Scheme} -configuration ${Config} DSTROOT=$WORKSPACE/build.dst OBJROOT=$WORKSPACE/build.obj \
SYMROOT=$WORKSPACE/build.sym SHARED_PRECOMPS_DIR=$WORKSPACE/build.pch

# Sign and export
if [ "$Target" == "helloJenkins-ios" ]; then
	if [ "$Config" == "Debug" ]; then
		/usr/bin/xcrun -sdk iphoneos PackageApplication -v $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.app -o $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.ipa --sign "iPhone Developer" --embed ${WORKSPACE}/autobuild/iOSTeam.mobileprovision
	fi
	if [ "$Config" == "Release" ]; then
		/usr/bin/xcrun -sdk iphoneos PackageApplication -v $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.app -o $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.ipa --sign "iPhone Distribution: Compuware Corporation" --embed ~/Downloads/Enterprise.mobileprovision
	fi
	# If you created a configuration for each environment (development, test, customer production)
	# You may need a seperate configuration created to build againt our internal servers (or for any specific environment)
	if [ "$Config" == "AutobuildRelease" ]; then
		/usr/bin/xcrun -sdk iphoneos PackageApplication -v $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.app -o $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.ipa --sign "iPhone Distribution: Compuware Corporation" --embed ~/Downloads/Enterprise.mobileprovision
		mv $WORKSPACE/build.sym/${Config}-iphoneos/${Target}.ipa ${WORKSPACE}/helloJenkins-ios.ipa
	fi
fi

# Test project
### Hello Jenkins has no unit tests.
#xcodebuild -target ${UnitTestTarget} -sdk iphonesimulator -configuration ${Config} TEST_AFTER_BUILD=YES clean build | $WORKSPACE/autobuild/ocunit2junit.rb

# move back to workspace
cd $WORKSPACE