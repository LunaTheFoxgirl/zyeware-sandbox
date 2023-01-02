DMGTITLE="Install Zyeware Sandbox"
DMGFILENAME="Install_Zyeware_Sandbox.dmg"

if [ -d "out/Zyeware Sandbox.app" ]; then
    if [ -f "out/$DMGFILENAME" ]; then
        echo "Removing prior install dmg..."
        rm "out/$DMGFILENAME"
    fi

    PREVPWD=$PWD
    cd out/
    echo "Building $DMGFILENAME..."

    # Create Install Volume directory

    if [ -d "InstallVolume" ]; then
        echo "Cleaning up old install volume..."
        rm -r InstallVolume
    fi

    mkdir -p InstallVolume
    cp ../LICENSE LICENSE
    cp -r "Zyeware Sandbox.app" "InstallVolume/Zyeware Sandbox.app"
    
    create-dmg \
        --volname "$DMGTITLE" \
        --volicon "ZyewareSandbox.icns" \
        --background "../res/dmgbg.png" \
        --window-size 800 600 \
        --icon "Zyeware Sandbox.app" 200 250 \
        --hide-extension "Zyeware Sandbox.app" \
        --eula "LICENSE" \
        --app-drop-link 600 250 \
        "$DMGFILENAME" InstallVolume/

    echo "Done! Cleaning up temporaries..."
    rm LICENSE

    echo "DMG generated as $PWD/$DMGFILENAME"
    cd $PREVPWD
else
    echo "Could not find ZyeWare Sandbox for packaging..."
fi