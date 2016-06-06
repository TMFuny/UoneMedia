#!/bin/bash


SF_TARGET_NAME="UOneMedia"
SF_EXECUTABLE_PATH="lib${SF_TARGET_NAME}.a"
SF_WRAPPER_NAME="${SF_TARGET_NAME}.framework"
SF_CURRENT_DIR=`pwd`
SF_BUILD_DIR=${SF_CURRENT_DIR}/build
SF_ACTION=build
if [[ "$1" = "silence" ]]
then
    SF_LOGGER='/dev/null'
else
    SF_LOGGER='/dev/stdout'
fi



echo "build i386 / x86_64 arch..."

SF_SDK_VERSION=`xcrun --show-sdk-platform-version --sdk iphonesimulator`
SF_SDK_ROOT=`xcrun --show-sdk-platform-path --sdk iphonesimulator`
SF_CONFIGURATION="Debug"

xcodebuild -project ${SF_CURRENT_DIR}/UOneMedia.xcodeproj ENABLE_BITCODE=YES -sdk "iphonesimulator${SF_SDK_VERSION}" -configuration "${SF_CONFIGURATION}" -target "UOneMediaStaticLib" BUILD_DIR="${SF_BUILD_DIR}" BUILD_ROOT="${SF_BUILD_DIR}" SYMROOT="${SF_BUILD_DIR}" -arch i386 -arch x86_64 build > $SF_LOGGER
#xcodebuild -project ${SF_CURRENT_DIR}/UOneMedia.xcodeproj ENABLE_BITCODE=YES -sdk "iphonesimulator${SF_SDK_VERSION}" -configuration "${SF_CONFIGURATION}" -target "UOneMediaStaticLib" BUILD_DIR="${SF_BUILD_DIR}" BUILD_ROOT="${SF_BUILD_DIR}" SYMROOT="${SF_BUILD_DIR}" -arch i386 build > $SF_LOGGER

echo "build arm7 / arm64 arch..."

SF_SDK_VERSION=`xcrun --show-sdk-platform-version --sdk iphoneos`
SF_SDK_ROOT=`xcrun --show-sdk-platform-path --sdk iphoneos`
SF_CONFIGURATION="Release"

#xcodebuild -project ${SF_CURRENT_DIR}/UOneMedia.xcodeproj ENABLE_BITCODE=YES -sdk "iphoneos${SF_SDK_VERSION}" -configuration "${SF_CONFIGURATION}" -target "UOneMediaStaticLib" BUILD_DIR="${SF_BUILD_DIR}" BUILD_ROOT="${SF_BUILD_DIR}" SYMROOT="${SF_BUILD_DIR}" -arch arm64 build > $SF_LOGGER
xcodebuild -project ${SF_CURRENT_DIR}/UOneMedia.xcodeproj ENABLE_BITCODE=YES -sdk "iphoneos${SF_SDK_VERSION}" -configuration "${SF_CONFIGURATION}" -target "UOneMediaStaticLib" BUILD_DIR="${SF_BUILD_DIR}" BUILD_ROOT="${SF_BUILD_DIR}" SYMROOT="${SF_BUILD_DIR}" -arch armv7 -arch arm64  build > $SF_LOGGER

echo "merge x86 / x86_64 / armv7 /arm64 arch static lib together .. "

lipo -create "${SF_BUILD_DIR}/Debug-iphonesimulator/${SF_EXECUTABLE_PATH}" "${SF_BUILD_DIR}/Release-iphoneos/${SF_EXECUTABLE_PATH}" -output "${SF_BUILD_DIR}/${SF_EXECUTABLE_PATH}"

echo "deploy UOneMeia.framework"
mkdir -p "${SF_CURRENT_DIR}/${SF_WRAPPER_NAME}/Versions/A/Headers"
/bin/cp -a "${SF_BUILD_DIR}/Release-iphoneos/include/public/" "${SF_CURRENT_DIR}/${SF_WRAPPER_NAME}/Versions/A/Headers"
/bin/cp -a "${SF_BUILD_DIR}/${SF_EXECUTABLE_PATH}" "${SF_CURRENT_DIR}/${SF_WRAPPER_NAME}/Versions/A/${SF_TARGET_NAME}"

pushd "${SF_CURRENT_DIR}/${SF_WRAPPER_NAME}/Versions" > $SF_LOGGER
/bin/ln -sfh "A" "Current"
/bin/ln -sfh "Versions/Current/Headers" "${SF_CURRENT_DIR}/${SF_WRAPPER_NAME}/Headers"
/bin/ln -sfh "Versions/Current/${SF_TARGET_NAME}" "${SF_CURRENT_DIR}/${SF_WRAPPER_NAME}/${SF_TARGET_NAME}"
popd > $SF_LOGGER

echo "install UOneMedia.bundle"
/bin/cp -a "${SF_BUILD_DIR}/Release-iphoneos/${SF_TARGET_NAME}.bundle" "${SF_CURRENT_DIR}"
