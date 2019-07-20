#! /usr/bin/env bash

set -eo pipefail
# set -euxo pipefail

echo "RFCI_TASK = $RFCI_TASK"
readonly RFWorkspace="B9MulticastDelegate"
readonly RFIsPackage=1
readonly RFSTAGE="$1"
echo "RFSTAGE = $RFSTAGE"

# Run test
# $1 scheme
# $2 destination
XC_Test() {
    xcodebuild test -enableCodeCoverage YES -workspace "$RFWorkspace" -scheme "$1" -destination "$2" ONLY_ACTIVE_ARCH=NO GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES | xcpretty
}

# Run macOS test
XC_TestMac() {
    if [ $RFIsPackage == 1 ]; then
        xcodebuild test -scheme "$RFWorkspace" -enableCodeCoverage YES GCC_GENERATE_TEST_COVERAGE_FILES=YES | xcpretty
    else
        xcodebuild test -enableCodeCoverage YES -workspace "$RFWorkspace" -scheme "Test-macOS" GCC_INSTRUMENT_PROGRAM_FLOW_ARCS=YES GCC_GENERATE_TEST_COVERAGE_FILES=YES | xcpretty
    fi
}

# Run watchOS test
XC_TestWatch() {
    xcodebuild build -workspace "$RFWorkspace" -scheme Target-watchOS ONLY_ACTIVE_ARCH=NO | xcpretty
}

STAGE_SETUP() {
    if [ "$RFCI_TASK" = "SwiftPM" ]; then
        if [ "$TRAVIS_OS_NAME" = "linux" ]; then
            echo "Download Swift"
            wget -q https://swift.org/builds/swift-5.0.2-release/ubuntu1404/swift-5.0.2-RELEASE/swift-5.0.2-RELEASE-ubuntu14.04.tar.gz
            tar xzf swift-5.0.2-RELEASE-ubuntu14.04.tar.gz
        fi
    fi

    # if [[ "$RFCI_TASK" == Xcode* ]]; then
    #     if [ $RFIsPackage == 1 ]; then
    #         swift package generate-xcodeproj --enable-code-coverage
    #     fi
    # fi
}

STAGE_MAIN() {
    if [[ "$TRAVIS_COMMIT_MESSAGE" = *"[skip ci]"* ]]; then
        echo "Skip CI"

    elif [ "$RFCI_TASK" = "POD_LINT" ]; then
        if [[ "$TRAVIS_COMMIT_MESSAGE" = *"[skip lint]"* ]]; then
            echo "Skip pod lint"
        else
            echo "TRAVIS_BRANCH = $TRAVIS_BRANCH"
            gem install cocoapods --no-rdoc --no-ri --no-document --quiet
            # Always allow warnings as third-party dependencies generate unavoidable warnings.
            pod lib lint --allow-warnings
        fi

    elif [ "$RFCI_TASK" = "SwiftPM" ]; then
        if [ "$TRAVIS_OS_NAME" = "linux" ]; then
            export PATH=${PWD}/swift-5.0.2-RELEASE-ubuntu14.04/usr/bin:"${PATH}"
            # Package should support Linux, but our test doesnt.
            swift --version
            swift build
        else
            swift --version
            swift test --parallel
        fi

    elif [ "$RFCI_TASK" = "Xcode11" ]; then
        XC_TestMac

    elif [ "$RFCI_TASK" = "Xcode9" ]; then
        XC_TestMac
        XC_Test "Example-iOS" "platform=iOS Simulator,name=iPhone 6,OS=11.2"
        # XC_Test "Example-iOS" "platform=iOS Simulator,name=X1,OS=11.3"
    else
        echo "Unexpected CI task: $RFCI_TASK"
    fi
}

STAGE_SUCCESS() {
    if [[ "$RFCI_TASK" == Xcode* ]]; then
        if [ $RFIsPackage == 1 ]; then
            bash <(curl -s https://codecov.io/bash)
        else
            bash <(curl -s https://codecov.io/bash)
        fi
    else
        echo "Skip STAGE_SUCCESS"
    fi
}

STAGE_FAILURE() {
    if [[ "$RFCI_TASK" == Xcode* ]]; then
        cat -n ~/Library/Logs/DiagnosticReports/xctest*.crash
    fi
}

"STAGE_$RFSTAGE"
