echo "Creating directory structure..."
LASTPWD=$PWD

# Handle copying all the dylibs to their respective directories
# As well handle creating our directory structure
cd out/Zyeware\ Sandbox.app/Contents

# Remove old files
if [ -d "Frameworks" ]; then
    echo "Removing files from prior bundle..."
    rm -r Frameworks SharedSupport Resources
    rm Info.plist
fi

# Create new directories and move dylibs
mkdir -p Frameworks SharedSupport Resources Resources/i18n
mv MacOS/libSDL2*.dylib Frameworks/libSDL2.dylib
mv -n MacOS/*.dylib Frameworks

# Move back to where we were
cd $LASTPWD

echo "Setting up file structure..."

# Copy info plist and icon
cp res/Info.plist out/Zyeware\ Sandbox.app/Contents/

# Move any translation files in if any.
mv -n out/*.mo out/Zyeware\ Sandbox.app/Contents/Resources/i18n/

# Copy license info to SharedSupport
cp res/*-LICENSE out/Zyeware\ Sandbox.app/Contents/SharedSupport/
cp LICENSE out/Zyeware\ Sandbox.app/Contents/SharedSupport/LICENSE


# Create icons dir
# TODO: check if dir exists, skip this step if it does
if [ ! -d "out/ZyewareSandbox.icns" ]; then
    iconutil -c icns -o out/ZyewareSandbox.icns res/Zyeware-Sandbox.iconset
else
    echo "Icons already exist, skipping..."
fi

echo "Applying Icon..."
cp out/ZyewareSandbox.icns out/Zyeware\ Sandbox.app/Contents/Resources/ZyewareSandbox.icns 

echo "Cleaning up..."
find out/Zyeware\ Sandbox.app/Contents/MacOS -type f ! -name "zyeware-sandbox" -delete

echo "Done!"