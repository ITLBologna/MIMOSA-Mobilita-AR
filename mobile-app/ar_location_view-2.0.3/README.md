# ar_location_view

Augmented reality for geolocation.
Inspired [HDAugmentedReality](https://github.com/DanijelHuis/HDAugmentedReality)


## Demo

![ArLocationView](./demo.gif)


## Description

ArLocationView is designed to used in areas with large concentration of static POIs.
Where primary goal is the visibility of all POIs.

**Remark:** Altitudes of POIs are disregarded


### Features
* Automatic vertical stacking of annotations views
* Tracks user movement and updates visible annotations
* Fully customisable annotation view
* Supports all rotations


### Basic usage
Look at the example

### For iOs
ArLocationView use device camera and location, add in `Info.plist`
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<key>NSLocationUsageDescription</key>
<key>NSLocationAlwaysUsageDescription</key>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<key>NSCameraUsageDescription</key>
```

1. Add the following to your `Podfile` file:

```ruby
   post_install do |installer|
     installer.pods_project.targets.each do |target|
       target.build_configurations.each do |config|
         config.build_settings['GCC_PREPROCESSOR_DEFINITIONS'] ||= [
           '$(inherited)',
           'PERMISSION_CAMERA=1',
           'PERMISSION_MICROPHONE=1',
           'PERMISSION_LOCATION=1',
           'PERMISSION_SENSORS=1',   
         ]
       end 
       # End of the permission_handler configuration
     end
   end
```

### For Android
Add permission in `manifest.xml`
```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```

Create class extend ArAnnotation

```dart
class Annotation extends ArAnnotation {
  final AnnotationType type;
  
  Annotation({required super.uid, required super.position, required this.type});
}
```

Create a widget for Annotation view for example
```dart

class AnnotationView extends StatelessWidget {
  const AnnotationView({
    Key? key,
    required this.annotation,
  }) : super(key: key);

  final Annotation annotation;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
              ),
              child: typeFactory(annotation.type),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    annotation.type.toString().substring(15),
                    maxLines: 1,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${annotation.distanceFromUser.toInt()} m',
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget typeFactory(AnnotationType type) {
    IconData iconData = Icons.ac_unit_outlined;
    Color color = Colors.teal;
    switch (type) {
      case AnnotationType.pharmacy:
        iconData = Icons.local_pharmacy_outlined;
        color = Colors.red;
        break;
      case AnnotationType.hotel:
        iconData = Icons.hotel_outlined;
        color = Colors.green;
        break;
      case AnnotationType.library:
        iconData = Icons.library_add_outlined;
        color = Colors.blue;
        break;
    }
    return Icon(
      iconData,
      size: 40,
      color: color,
    );
  }
}
```

## License

ArLocationView is released under the MIT license.

## Contributors


<!-- ALL-CONTRIBUTORS-LIST:START - Do not remove or modify this section -->
<!-- prettier-ignore-start -->
<!-- markdownlint-disable -->

<table>
    <tbody>
        <tr>
            <td align="center">
                <img src="https://avatars.githubusercontent.com/u/33430575?v=4?s=100" width="100px;" alt="Pierre Rakotodimimanana" />
                <br/>
                <a href="https://github.com/Melo567" title="Code">
                    <b>Pierre Rakotodimimanana</b>
                </a>
            </td>
            <td align="center">
                <img src="https://avatars.githubusercontent.com/u/92214521?s=400&u=50323c144888990cb6ad01c81d369926ecfa91a2&v=4?s=100"
                    width="100px;" alt="Misa Johary" />
                    <br/>
                <a href="https://github.com/misaJohary" title="Code">
                    <b>Misa Johary</b>
                </a>
            </td>
            <td align="center"><img src="https://avatars.githubusercontent.com/u/94055176?v=4?s=100" width="100px;"
                    alt="Jean Léonce" /><br/>
                <a href="https://github.com/rakotoleonce2106" title="Code">
                    <b>Jean Léonce</b>
                </a>
            </td>
        </tr>
    </tbody>
</table>

<!-- markdownlint-restore -->
<!-- prettier-ignore-end -->

<!-- ALL-CONTRIBUTORS-LIST:END -->