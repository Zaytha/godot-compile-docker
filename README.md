## Godot Compile Docker

This is a .bat and docker compose file used to create the build environment and build binaries for [Godot](https://godotengine.org/) with [GodotSteam](https://godotsteam.com/) and [PCK Encryption](https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_with_script_encryption_key.html).

The resulting files will be created in the godot_data directory, containing the godot source code, the godot.gdkey for encryption, and the binaries (located in godot_data/godot/bin/)

In my testing, trying to cross compile GodotSteam for windows on a linux machine would cause build issues. So this setup requires you run it on a Windows machine with docker and WSL. 
The environment setup and linux build take place in a WSL docker contianer, while the windows build happens the local machine (after the linux build is complete).



## Requirements
This must be run on a Windows machine with WSL and docker (docker must be using linux containers) 


You must download the [Steamworks SDK](https://partner.steamgames.com/?ref=stebet.net) (which requires having a steamworks account) and place the contents of the zip file in the steam_sdk folder.
After extration the setup should look like this:
```
godot-compile-docker/
└─ steam_sdk/
   └─ sdk/*
```

## Usage Notes
After compiling, make sure to follow the [Godot PCK Encryption Guide](https://docs.godotengine.org/en/stable/contributing/development/compiling/compiling_with_script_encryption_key.html) for creating export templates, as by default  there is no encryption. You need to enable it and pass in the encryption key.


If you move the files out of the bin folder, make sure to copy the steam shared libraries along with them, or you won't be able to open the editor. These shared libraries also need to be included with your exported game files for the game to function.
- `libsteam_api.so` for linux
- `steam_api64.dll` and `steam_api64.lib` for windows
- These are also available in `godot-compile-docker/steam_sdk/sdk/redistributable_bin/` or `godot-compile-docker/godot_data/godot/modules/godotsteam/sdk/redistributable_bin/` 
