
# react-native-custom-share

Github repo: https://github.com/nascimentorafael/react-native-custom-share

## Getting started

`$ npm install react-native-custom-share --save`

### Mostly automatic installation

`$ react-native link react-native-custom-share`

### Manual installation

#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-custom-share` and add `RNCustomShare.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNCustomShare.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNCustomSharePackage;` to the imports at the top of the file
  - Add `new RNCustomSharePackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-custom-share'
  	project(':react-native-custom-share').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-custom-share/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-custom-share')
  	```

## Usage
```javascript
import RNCustomShare from 'react-native-custom-share';

// TODO: What to do with the module?
RNCustomShare;
```
