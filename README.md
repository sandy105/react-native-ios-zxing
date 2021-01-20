
# react-native-ios-zxing

## Getting started

`$ npm install react-native-ios-zxing --save`

### Mostly automatic installation

`$ react-native link react-native-ios-zxing`

### Manual installation


#### iOS

1. In XCode, in the project navigator, right click `Libraries` ➜ `Add Files to [your project's name]`
2. Go to `node_modules` ➜ `react-native-ios-zxing` and add `RNIosZxing.xcodeproj`
3. In XCode, in the project navigator, select your project. Add `libRNIosZxing.a` to your project's `Build Phases` ➜ `Link Binary With Libraries`
4. Run your project (`Cmd+R`)<

#### Android

1. Open up `android/app/src/main/java/[...]/MainActivity.java`
  - Add `import com.reactlibrary.RNIosZxingPackage;` to the imports at the top of the file
  - Add `new RNIosZxingPackage()` to the list returned by the `getPackages()` method
2. Append the following lines to `android/settings.gradle`:
  	```
  	include ':react-native-ios-zxing'
  	project(':react-native-ios-zxing').projectDir = new File(rootProject.projectDir, 	'../node_modules/react-native-ios-zxing/android')
  	```
3. Insert the following lines inside the dependencies block in `android/app/build.gradle`:
  	```
      compile project(':react-native-ios-zxing')
  	```

#### Windows
[Read it! :D](https://github.com/ReactWindows/react-native)

1. In Visual Studio add the `RNIosZxing.sln` in `node_modules/react-native-ios-zxing/windows/RNIosZxing.sln` folder to their solution, reference from their app.
2. Open up your `MainPage.cs` app
  - Add `using Ios.Zxing.RNIosZxing;` to the usings at the top of the file
  - Add `new RNIosZxingPackage()` to the `List<IReactPackage>` returned by the `Packages` method


## Usage
```javascript
import { RNZxingScan } from "react-native-ios-zxing";

 <View style={{flex: 1}}>
          <RNZxingScan onBarCodeRead = {(data) => {Alert.alert(data.format,data.content)}} />
</View>
```
