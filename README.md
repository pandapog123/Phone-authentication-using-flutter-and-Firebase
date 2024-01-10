# Phone authentication using flutter and Firebase

## Resources

- [Flutter documentation](https://docs.flutter.dev)
- [Flutter cli installation documentation](https://docs.flutter.dev/reference/flutter-cli)
- [Bloc library documentation](https://bloclibrary.dev/#/gettingstarted)
- [Adding Firebase to your Flutter application](https://firebase.google.com/docs/flutter/setup?platform=ios)
- [Stack overflow answer for issue on Firebase packages not working with Flutter](https://stackoverflow.com/questions/77219650/dt-toolchain-dir-cannot-be-used-to-evaluate-library-search-paths-use-toolchain)
- [Phone number package documentation](https://pub.dev/packages/phone_number)
- [Firebase phone number authentication documentation](https://firebase.google.com/docs/auth/flutter/phone-auth)
- [Firebase iOS phone number auth docs](https://firebase.google.com/docs/auth/ios/phone-auth)

## Steps to duplicate

- Go to [the Firebase console](https://console.firebase.google.com/) and create a new project with **Phone Authentication** enabled
- Run `flutter create . --org com.danigorra --project-name phone_auth_firebase`
- Run `flutter pub add bloc flutter_bloc go_router firebase_core firebase_auth phone_number equatable`
- Run `firebase login` to ensure you are authenticated to your account in the CLI, then run `flutterfire configure` and select the project you just created
- Follow the [**Setup for the phone_number package** for iOS](https://pub.dev/packages/phone_number#setup)
- Run `pod repo update` and then `pod install --repo-update` inside the `ios` folder to ensure that the dependencies can be installed for iOS
- Ensure that you have [**Android studio**](https://developer.android.com/studio) and/or [**Xcode**](https://apps.apple.com/us/app/xcode/id497799835) installed
- You can download the **flutterfire** cli by running `dart pub global activate flutterfire_cli`
