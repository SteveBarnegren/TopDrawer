![icon](https://user-images.githubusercontent.com/6288713/34445381-3baca576-eccb-11e7-953c-b45c3f0d1590.png)

**Top-Drawer gives you quick access to the files you use most straight from your MenuBar!**

![Gif](https://user-images.githubusercontent.com/6288713/34445419-74ca1f3c-eccb-11e7-9715-c5c1d017d5a7.gif)

Simply tell **Top-Drawer** what kind of files you want to see, and where to find them, and it will do the rest.

## How to use

Set a route directory, in this case `Projects`.

Add a rule to show any files with extension `.workspace` or `.xcodeproj`: 

![simple settings](https://user-images.githubusercontent.com/6288713/34445447-a415ee7e-eccb-11e7-918e-0671838d8dbb.png)

**TopDrawer** will find your files for quick access from the Menu Bar:

![simple menu](https://user-images.githubusercontent.com/6288713/34445450-a73471b6-eccb-11e7-8957-fef1e8d707b7.png)

## Getting Fancy

Rules can have any number of conditions.

Here, we show any `xcodeproj` files, but not if the parent directory also contains an `xcworkspace` file.

We might also be interested in files called `podfile`, but not if the extenion is `.lock`:

![complex settings](https://user-images.githubusercontent.com/6288713/34445456-aabc6ca8-eccb-11e7-8ac1-45338f364517.png)

## Features

- Add rules with multiple conditions for finding files
- Add rules to exclude folders
- Shorten paths, no more navigating through 'connecting' folders
- Aliases? No problem
- Open at login
- Adjustable search frequency
- Option to open at login

## How to install

Either build from source, or install the the prebuilt binary here: ...

## Contributing

I welcome contributions and discussion for new features or bug fixes. It is recommended to file an issue first to prevent unnecessary efforts, but feel free to put in pull requests in the case of trivial changes. In any other case, please feel free to open discussion and I will get back to you when possible.

## Author

Follow me on twitter [@SteveBarnegren](https://twitter.com/stevebarnegren)

## License

TopDrawer is available under the ??? license. See the LICENSE file for more info.
