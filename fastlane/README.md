fastlane documentation
================
# Installation

Make sure you have the latest version of the Xcode command line tools installed:

```
xcode-select --install
```

Install _fastlane_ using
```
[sudo] gem install fastlane -NV
```
or alternatively using `brew cask install fastlane`

# Available Actions
## iOS
### ios dependencies
```
fastlane ios dependencies
```
Installs dependencies
### ios build_ipa
```
fastlane ios build_ipa
```
Build ipa
### ios screenshots
```
fastlane ios screenshots
```
Create App Store Screenshots
### ios deploy_develop
```
fastlane ios deploy_develop
```
Deploys App to AppCenter
### ios deploy_master
```
fastlane ios deploy_master
```
Deploys App to AppStore

----

This README.md is auto-generated and will be re-generated every time [fastlane](https://fastlane.tools) is run.
More information about fastlane can be found on [fastlane.tools](https://fastlane.tools).
The documentation of fastlane can be found on [docs.fastlane.tools](https://docs.fastlane.tools).
