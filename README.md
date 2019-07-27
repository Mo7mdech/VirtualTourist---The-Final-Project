# VirtualTourist---The-Final-Project
An app that downloads and stores images from Flickr. The app will allow users to drop pins on a map, as if they were stops on a tour. Users will then be able to download pictures for the location and persist both the pictures, and the association of the pictures with the pin

This project is an IOS application for Udacity IOS developer ND program. An upgraded version of Virtual Tourist which fits The Final Project. it Includes:

an activity indicator
alert message pops out if the application is not connected to the internet
a README file
When the app first starts it will open to the map view. Users will be able to zoom and scroll around the map using standard pinch and drag gestures.

Tapping and holding the map drops a new pin. Users can place any number of pins on the map.

When a pin is tapped, the app will navigate to the Photo Album view associated with the pin. If the user taps a pin that does not yet have a photo album, the app will download Flickr images associated with the latitude and longitude of the pin. If no images are found a “No Images” label will be displayed. If there are images, then they will be displayed in a collection view.

While the images are downloading, the photo album is in a temporary “downloading” state in which the New Collection button is disabled.

Once the images have all been downloaded, the app should enable the New Collection button at the bottom of the page. Tapping this button should empty the photo album and fetch a new set of images. Note that in locations that have a fairly static set of Flickr images, “new” images might overlap with previous collections of images.

Users are able to remove photos from an album by tapping them. Tapping the back button will return the user to the Map view.

How To Build :

to build this app you will need to daownload xcode which requiers mac OS

Requirements :

the deployment target is ios 12.3
the app can build on both iphone and ipad
