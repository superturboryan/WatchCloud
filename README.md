# WatchCloud ⌚️☁️

*watchOS client for SoundCloud*


## Running the app

1. Add a configuration file to [WatchCloud Watch App/Config/](WatchCloud%20Watch%20App/Config) with the following values:

```swift
//  Config.xcconfig
//  Ensure this is ignored by source control since it contains private keys 🚨    

SC_CLIENT_ID = ...
SC_CLIENT_SECRET = ...
SC_REDIRECT_URI = ...
MP_PROJECT_TOKEN = ...
```

2. Set the configuration under *Project > Configurations*.

3. Select *WatchCloud Watch App* scheme and *watchOS device* run destination.

4. Run! 🕺💃  


## App Store  

Country pages: [🇺🇸](https://apps.apple.com/us/app/watchcloud/id6466678799) [🇨🇦](https://apps.apple.com/ca/app/watchcloud/id6466678799) [🇬🇧](https://apps.apple.com/gb/app/watchcloud/id6466678799) [🇫🇷](https://apps.apple.com/fr/app/watchcloud/id6466678799) [🇩🇪](https://apps.apple.com/de/app/watchcloud/id6466678799)

📚 [Localized App Store page copy](https://docs.google.com/spreadsheets/d/1X5ar5NwSw0vT7UX9HCABxrts76Y-qbuUrhhyNw4LlDM/edit?usp=sharing)


## Screenshots (1.1.5)

<p float="center">
    <img src="Screenshots/1.1.0/LoginView%20-%20S945.png" width=200 alt="Login screen"/>
    <img src="Screenshots/1.1.2/LibraryView%20-%20S945.png" width=200 alt="Library screen"/>
    <img src="Screenshots/1.1.0/Liked%20Playlists%20-%20S945.png" width=200 alt="Liked playlists screen"/>
    <img src="Screenshots/1.1.5/PlaylistView%20-%20S945.png" width=200 alt="Playlist screen"/>
</p>

<br />

<p float="center">
    <img src="Screenshots/1.1.0/UserDetailView%20Top%20Tracks%20-%20S945.png" width=200 alt="User top tracks screen"/>
    <img src="Screenshots/1.1.5/PlayerView%20-%20S945.png" width=200 alt="Player screen"/>
    <img src="Screenshots/1.1.2/PlayerView%20-%20S945.png" width=200 alt="Player screen"/>
    <img src="Screenshots/1.1.2/PlayerOptionsView%20-%20S945.png" width=200 alt="Player options screen"/>
</p>

<br />

<p float="center">
    <img src="Screenshots/1.1.2/SearchView%20-%20S945.png" width=200 alt="Search screen"/>
    <img src="Screenshots/1.1.0/UserListView%20-%20S945.png" width=200 alt="User list screen"/>
    <img src="Screenshots/1.1.5/UserDetailView%20-%20S945.png" width=200 alt="User detail screen"/>
    <img src="Screenshots/1.1.2/LibraryView%20Bottom%20-%20S945.png" width=200 alt="Library screen bottom"/>
</p>


## Dependencies
📦 [KeychainSwift](https://github.com/evgenyneu/keychain-swift/)  
📦 [Mixpanel](https://github.com/mixpanel/mixpanel-swift)    
📦 [Nuke](https://github.com/kean/Nuke)  
📦 [QRCode](https://github.com/dagronf/QRCode)  
📦 [SoundCloud-Swift](https://github.com/superturboryan/SoundCloud-api)    
