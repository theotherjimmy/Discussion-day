# About

Discussion-day is an android application that helps teachers track student understanding of material through random sampling.
The sampling is done by the application so that a user would simply call a student by name during an in class discussion and record how the student responded in three categorys: correct, incorrect, and decided not to awnser or pass.
Discussion-day will allow the user to view totals for classes, discussions, and students.
It can also display totals for students per discussion and totals for discussions per student.

Discussion-day is also an example a kawa scheme android application.

# Installation

## Android Build Environment

First download and extract the platform appropriate android sdk. A few platforms are listed on the [Android SDK Page](http://developer.android.com/sdk/index.html).

Next add the tools and platform tools directories to your path. for examlpe:

````bash
$ cd extracted/android/sdk
$ export PATH=$PATH:$(pwd)/sdk/tools:$(pwd)/sdk/platform-tools
````

Finaly, download the appropriate android sdk for your phone's android version.
The easiest way to ensure that this is done correctly is to run the `android` command.
A table that relates android release numbers (like 2.3.3) to sdk revisions (like android-10) may be found [as part of the Use SDK XML Element description](http://developer.android.com/guide/topics/manifest/uses-sdk-element.html#ApiLevels). (scroll a bit brother)

## Building Discussion-day

Now you can update the configuration of Discussion-day to fit your device and sdk location.
This can easily be done with the `android update project` command.
For example, if you have android gingerbread (2.3.7), your update command would look like this:

````bash
$ android update project --target android-10 --path path/to/Discussion-day/root/dir
````

Discussion-day's sources are now configured to build on your system.
Next, build the project with `and debug`:

````bash
$ cd path/to/Discussion-day/root/dir
$ ant debug
````

or if you're feeling mighty adventerous, you can build and install in one command:

````bash
$ cd path/to/Discussion-day/root/dir
$ ant debug && ant uninstall && ant installd
````

I added the uninstall command to ensure that it will install on the target device even if you have installed it before. The 'd' in `installd` stand for debug, the release type.

# TODO
Export!

# Bugs and feature requests

Please, report any problems that you find on the projects integrated issue tracker.
If you've added some improvements and you want them included upstream don't hesitate to send me a patch or even better - a GitHub pull request.

Enjoy,</br>
Jimmy