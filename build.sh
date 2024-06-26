#!/bin/sh

# MCODE project configuration where
# - sourceDir contains
#   - MCODE source files (extension .src)
#   - linker file ${projectName}.lnk
#   - (optional) emulator loader file ${projectName}.lod
# - buildDir is the target for all output files
# Note that all files in $sourceDir are expected to have CR LF
# line terminators! You may use command 'file ${sourceDir}/*'
# to check that.

sourceDir=./src
buildDir=./build

# Get absolute path of build script
SCRIPT_PATH="$(cd $(dirname $0); pwd -P)"

# Delete $buildDir, see build target 'clean'
doClean() {
  echo "clean"
  rm -rf $buildDir
  return 0
}

# Guess project name from linker file name
guessProjectName() {
    files=($sourceDir/*.lnk)
    pathName=${files[0]}
    fileName=$(basename $pathName)
    echo "${fileName%.*}"
}

# Copy source files from source to build directory
prepareBuildDir() {
    mkdir -p $buildDir
    # copy source, linker and load files
    cp $sourceDir/*.{src,lnk,lod} $buildDir
    # copy standard emulator ROM images
    cp $SDK41/*.ROM $buildDir
}

# Create batch file to compile and link MCODE project
# using the SDK41 compiler/linker
createDosBuildScript() {
    buildHelper="$(cd $buildDir; pwd -P)/build.bat"
    echo "l41 /arol /ll /r $1 > build.log" > $buildHelper
    # DOS needs CR LF line terminators
    unix2dos -q $buildHelper
    echo "$buildHelper"
}

# Call DOSBox to run batch file (SDK41 in path)
runDosScript() {
    open -a DOSBOX $1 \
        --args "$2" -exit -c "mount d $SDK41" -c "path d:/"
}

runDosScriptHidden() { runDosScript -Wnj $1; }
runDosScriptInteractive() { runDosScript -Wn $1; }

# Just for convenience: convert DOS upper case filenames to
# lower case
lowerCaseFileNames() {
    local path="$1"
    for i in $path; do
        j=$(echo "$i" | tr '[:upper:]' '[:lower:]')
        mv "$i" "$j"
    done
}

# Create batch file to run MCODE project in HP-41 emulator
createDosTestScript() {
    testScript="$(cd $buildDir; pwd -P)/test.bat"
    echo "m41 /j /$1" > $testScript
    # DOS needs CR LF line terminators
    unix2dos -q $testScript
    echo "$testScript"
}

# Build project, see build target 'build'
doBuild() {
    local projectName="$1"
    echo "build $projectName"
    prepareBuildDir
    local buildScript=$(createDosBuildScript $projectName)
    runDosScriptHidden "$buildScript"
    lowerCaseFileNames "$buildDir/*"
    grep "\*\*\* ERROR" $buildDir/build.log
    if [ $? -eq 1 ]; then
        echo "DONE"
        return 0
    else
        return 1
    fi
}

# Debug project, see built target 'test'
doTest() {
    local projectName="$1"
    doBuild "$projectName"
    echo "test $1"
    local testScript=$(createDosTestScript $projectName)
    runDosScriptInteractive "$testScript"
    return 0
}

# Deploy project to HP-41CL, see built target 'deploy'
doDeploy() {
    local projectName="$1"
    doBuild "$projectName"
    echo "deploy $1"
    echo "\033[0;31mGet ready to start receive program on your HP-41CL\033[0m"
    sleep 2
    java -jar $CLUPDATE --upload build/${projectName}.rom $USBSERIAL 4800
    return 0
}

# Environment variable SDK41 defines path to SDK41
if [ -z "$SDK41" ]; then
    echo "*** error: path to HP-41 SDK not set"
    exit 1
elif  [ "$1" == "clean" ]; then
    doClean
    exit $?
elif [ "$1" == "" ] || [ "$1" == "build" ]; then
    doBuild "$(guessProjectName)"
    exit $?
elif [ "$1" == "test" ]; then
    doTest "$(guessProjectName)"
    exit $?
elif [ "$1" == "deploy" ]; then
    if [ -z "$CLUPDATE" ]; then
        echo "*** error: path to HP-41CL update program not set"
        exit 1
    fi
    if [ -z "$USBSERIAL" ]; then
        echo "*** error: USB serial device name not set"
        exit 1
    fi
    doDeploy "$(guessProjectName)"
    exit $?
else
    echo "*** error: unknown build target"
    exit 1
fi
