# Sightr - Travel Guide

Sightr allows users to create their own travel guides that can be shared with others.

Every time the user gets near a predefined interesting place (guide point) a local notification gets fired and the user will be provided with information about the guide point.

## Used APIs

- Region Monitoring API (Core Location)
- Local Notifications
- AirDrop with UTI
- Social Sharing
- Realm Database
- Google Maps

## Limitations

- A guide point cannot contain more than one image.
- Every guide point needs at least a title, description, radius in meters (for the Geofence) and a location (latitude and longitude).
- The app needs a network connection, GPS enabled and for the 'Sharing' function AirDrop enabled.

## Known issues

- 'Sharing with AirDrop' has sometimes difficulties to find a Mac device (maybe problem of OS itself?). However, sharing with AirDrop between two iPhones works.

## Installation notes

In order to build and execute the app, the pods listed in the provided 'Podfile' need to be installed first.

## Tested devices

- iPhone 6s with iOS 9.3.1
- Developed in Xcode 7.3.1