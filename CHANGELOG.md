# 1.2.0
🌎 Published _  
🔨 Xcode 15.0  
⌚️ watchOS 10.0  
📦 **SoundCloud Swift Package 1.0.3 ⭐️**  

### ✨ Features
- Loaded track + queue are saved when app is backgrounded, loaded on app launch
- Portuguese (pt-br), Dutch localizations
- SettingsView
    - Toggle displaying QR code
    - Toggle allowing downloading over data
    - View total downloads size
    - Remove all downloads

### 🐞 Bug fixes
- **AudioPlayer uses HLS streaming URLs (instead of mp3)** ‼️🤦‍♂️
- AudioPlayer uses `Nuke.ImagePipeline` to load artwork
- Remove @MainActor from AudioPlayer class declaration, add to methods instead
- LoginView displays tip when login is cancelled
- Translation, capitalization fixes
- AudioPlayer loads images using Nuke.ImagePipeline
- Add padding to CachedImageView's fallback image
- Show alert when liking track or starting download fails
- Add UserListView empty state


# 1.1.5
🌎 Published 18 November  
🔨 Xcode 15.0  
⌚️ watchOS 10.0  
📦 SoundCloud Swift Package 1.0.1   

### 🐞 Bug fixes
- New installs weren't being shown login screen! 
    - Check if UserStore throws error when loading, perform logout


# 1.1.4
🌎 Published 17 November  
🔨 Xcode 15.0  
⌚️ watchOS 10.0  
📦 **SoundCloud Swift Package 1.0.1 ⭐️**  

### ✨ Features
- Fast-forward + rewind tracks
- Unit tests

### 🐞 Bug fixes
- Number formatting for 1000s doesn't show decimal (123.4k -> 123k)


# 1.1.3
🌎 Published 26 October  
🔨 Xcode 15.0  
⌚️ watchOS 10.0  
📦 SoundCloud Swift Package 1.0.0  

### 🐞 Bug fixes
- Add @MainActor back to AudioPlayer class declaration
- Localized search history strings


# 1.1.2
🌎 Published 24 October  
🔨 Xcode 15.0  
⌚️ watchOS 10.0  
📦 **SoundCloud Swift Package 1.0.0 ⭐️**  

### ✨ Features
- Display QR code instead of artwork when lumininance is reduced
- Display search history
- Improve like + follow performance

### 🐞 Bug fixes
- Small UI tweaks


# 1.1.1
🌎 Published 16 October  
🔨 Xcode 15.0  
⌚️ watchOS 10.0  
📦 SoundCloud Swift Package 0.0.3  

### ✨ Features
- Italian, Japanese localizations

### 🐞 Bug fixes
- Hide shuffle button in track search results page
- Format number of followers for millions
- PlayerOptionsView: adjust padding for buttons, use gradient for speed text


# 1.1.0
🌎 Published 11 October  
🔨 Xcode 15.0  
⌚️ watchOS 10.0      
📦 SoundCloud Swift Package 0.0.3  

### ✨ Features
- View followed artists
- Artist detail view w/ most played, recent, liked tracks, description
- View most played, recent, liked tracks playlists
- Search (tracks, playlists, artists) + results pages
- Shuffle now playing playlist
- CaptchaNotAppearing tip

### 🐞 Bug fixes
- Use larger avatar image url
- Use device screen size instead of GeometryReader
- Display Playlist.tracksCount instead of Playlist.tracks.count in PlaylistSummaryView


# 1.0.3
🌎 Published 2 October  
🔨 Xcode 15.0  
⌚️ watchOS 10.0  
📦 SoundCloud Swift Package 0.0.3

### ✨ Features
- Use new .contentTransition(.symbolEffect(.replace)) for icon transitions

### 🐞 Bug fixes
- Add .lproj folder for all localizations
- Standardize image view used in NewPlayerView and PlaylistView
- Remove subcription label from CurrentUserView
- Old PlayerView: stop animating playback time labels, remove offset from toolbar button
- CurrentUserView: hide navigation bar bg (clipping image on SE44)


# 1.0.2
🌎 Published 27 September  
🔨 Xcode 15.0  
⌚️ watchOS 10.0  
📦 **SoundCloud Swift Package 0.0.3 ⭐️**

### ✨ Features
- Redesigned PlayerView for watchOS 10: bottom toolbar, show track artwork
- Spanish (LATAM), Arabic localizations

### 🐞 Bug fixes
- Strings not localized, translation errors
- Info.plist missing localizations array
- PlayerOptionsView background not taking up full size


# 1.0.1
🌎 Published 23 September  
🔨 **Xcode 15.0 ⭐️**  
⌚️ **watchOS 10.0 ⭐️**  
📦 **SoundCloud Swift Package 0.0.2 ⭐️**

### ✨ Features
- Watch complication: open app (circular, corner)
- French, German, Korean localizations

### 🐞 Bug fixes
- CurrentUserView: share button UI
- LoginView: hide close button added in watchOS 10
- LoginView: replace blurry _Connect with SoundCloud_ button with SF symbol-based login button
- LoginView: don't show error alert when user cancels login flow
- PlayerView: fix time remaining going to 0 when time remaining was exactly 1 hour, animate changes
- PlayerOptionsView: toggling playback speed doesn't start music if stopped
- PlayerOptionsView: add black bg to (new watchOS 10 material bg was too translucent)


# 1.0 🐣
🌎 Published 19 September  
🔨 Xcode 14.3.1  
⌚️ watchOS 9.4  
📦 SoundCloud Swift Package 0.0.1
  
### ✨ Features
- Sign in with SoundCloud account, refresh OAuth access token
- Play music
- Access playlists 
    - Liked tracks 
    - Recently posted 
    - Liked playlists 
    - My playlists
- Shuffle playlist
- Liked tracks pagination
- Like-unlike tracks
- Share tracks, playlists, my profile
- Change playback speed
- OS media controls
- **Minimum watchOS: 9.1**
