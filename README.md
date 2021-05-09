![icon](https://user-images.githubusercontent.com/6288713/34455063-b66a46f8-ed6e-11e7-972f-c3ed6ff88e40.png)

![version](https://img.shields.io/github/tag/SteveBarnegren/TopDrawer.svg)
![min](https://img.shields.io/badge/min-macOS%2010.12-lightgrey.svg)
![build](https://img.shields.io/travis/SteveBarnegren/TopDrawer/master.svg)


**Top-Drawer gives you quick access to the files you use most straight from your menu bar!**

Simply tell **Top-Drawer** what kind of files you want to see, and where to find them!

![gif 5](https://user-images.githubusercontent.com/6288713/34454891-54d29078-ed6c-11e7-91a3-bf1676c6af7b.gif)

## How to use

Set a root folder, in this case `Projects`.

Add rules to match the files that you want to see, in this example, files with the extension `.workspace` or `.xcodeproj`:

![simple settings with menu](https://user-images.githubusercontent.com/6288713/34537750-6e991312-f0c1-11e7-8d5a-ef0c79c0f75d.png)

## More complex rules

Rules can have any number of conditions.

Here, we show any `xcodeproj` files, but not if the parent directory also contains an `xcworkspace` file.

We might also be interested in files called `podfile`, but not if the extension is `.lock`:

![complex settings](https://user-images.githubusercontent.com/6288713/34445456-aabc6ca8-eccb-11e7-8ac1-45338f364517.png)

## Folder exclusion rules

Often, there are cases where a program that you use might create its own folders that contain the same kinds of files that you are interested in. In these cases, you can use a folder exclusion rule to omit a folder from the search.

Here, we exclude any folders called `Pods`:

![pods](https://user-images.githubusercontent.com/6288713/34455034-1f6c7c3a-ed6e-11e7-8e47-008655f4b571.png)

## Features

- Add rules with multiple conditions for finding files
- Add rules to exclude folders
- Shorten paths, no more navigating through 'connecting' folders
- Aliases? No problem
- Adjustable search frequency
- Option to open at login
- Open a folder in Terminal (thanks [Josh Rideout](https://github.com/Jride))

## How to install

Either build from source, or download the app: [Top-Drawer](https://github.com/SteveBarnegren/TopDrawer/releases)

## Contributing

I welcome contributions and discussion for new features or bug fixes. It is recommended to file an issue first to prevent unnecessary efforts, but feel free to put in pull requests in the case of trivial changes. In any other case, please feel free to open discussion and I will get back to you when possible.

## Author

Follow me on twitter [@SteveBarnegren](https://twitter.com/stevebarnegren)

## License

TopDrawer is available under the MIT license. See the LICENSE file for more info.