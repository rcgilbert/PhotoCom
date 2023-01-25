#  PhotoCom

A simple app that displays photo albums from a demo API.

## Assumptions
- API data can be cached in-memory for the lifecycle of the app after initial loads.  
- Thumbnail and photos can be safely cached for the lifecycle of the app without adversly effecting user experience.


## Decisions 
- Use an MVVM architecture for easy testability and better separation of concerns. 
- Storing data on-disk is outside the scope of this version. 
- An interactive dismiss transition is outside the scope of this version. 

## Requirements

Create an app using Swift (UIKit) and an architecture of your choice that meets the following high-level requirements:

- Shows a list of album titles returned by https://jsonplaceholder.typicode.com/albums with the name of the user the album belongs to.
- This is the users endpoint https://jsonplaceholder.typicode.com/users
- When an album is clicked, show its photos returned by https://jsonplaceholder.typicode.com/photos as a thumbnail
- When a thumbnail is clicked, the full sized photo should be displayed
- Only information that will be presented should be loaded
- Include at least one unit test
- Please include all assumptions/decisions made in a readme file

## Notes

- Photo Gallery Animation adapted from https://github.com/masamichiueta/FluidPhoto

