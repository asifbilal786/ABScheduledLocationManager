# ABWebView
A utility control to fetch locations with a specified interval of time even in the background.

<!--## Demo-->
<!--![Alt text](http://i.imgur.com/pwTgDH8.gif "")-->

## Requirements

- iOS 8 and above.
- Xcode 8 and above


## Adding ABScheduledLocationManager to your project

### METHOD 1:
1. Add a pod entry for `ABScheduledLocationManager` to your Podfile

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'ABScheduledLocationManager', '~> 0.1'
``` 

2. Install the pod(s) by running `pod install`.

### MEHTOD 2: (Source files)
Alternatively, you can directly add all files under the folder Core to your project.

1. Download the [latest code version](https://github.com/asifbilal786/ABScheduledLocationManager/archive/master.zip) or add the repository as a git submodule to your git-tracked project.
2. Open your Xcode project, then drag and drop source directory onto your project. Make sure to select Copy items when asked if you extracted the code archive outside of your project.
 

## Usage

Create instance of ABScheduledLocationManager and set it's delegate. And use it like given below:

```
lazy var scheduleLocationManager = ScheduledLocationManager()

//Start Location Manager
scheduleLocationManager.getUserLocationWithInterval(interval: 10)
scheduleLocationManager.delegate = self

//Stop Location Manager
scheduleLocationManager.stopGettingUserLocation()
```

See example projects for detail.

## License
This code is distributed under the terms and conditions of the [MIT license](LICENSE). 

