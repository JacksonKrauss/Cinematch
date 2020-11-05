# Cinematch
Team 15

## Contributions:
### Jackson Krauss (Release 25%, overall 29.5%)
* Create view controllers for each screen
* Add Segues between Controllers
* Add elements to splash screen
* Add elements to initial screen
* Add elements to home screen
* Add elements to watchlist (grid) screen
* Home screen functionality
* Send to friends screen
* Watchlist functionality
* Adding info from the movies to screens
* Add app icon
*  Watchlist search functionality
---
*  Pulled movie info from API to all movie locations
* Basic suggestion engine based on movies that are liked
* Store swiped on movies in firebase and load them
* Added movies to profile screen
* Change color of button on movie detail screen based on user opinion
* Added indicators to swipe screen to make it clear what direction means what
* Added list of actors to movie detail page

### Maegan Parfan (Release 25%, Overall 23.5%)
* Created login and sign-up screens
* Created the user profile and friend profile screens
* Implemented the back buttons in the login and sign-up screens
* Implemented login and sign-up Firebase authentication
* Implemented search screen functionality and cell styling
---
* Fixed profile and login/signup bugs
* Implemented logout segue logic
* Implemented all of the settings functionality, including updating/storing data in Firebase
* Implemented some default user behavior
* Added keyboard dismissal to all relevant view controllers

### Kyle Knight (Release 25%, overall 23.5%)
* Create Firebase 
* Create placeholder users
* Add elements to movie screen
* Add elements to the friends screen
* User data in profile screen
* Profile screen segmented control/collection view
* Friends data in friends screen
* Friends screen collection view layout
---
* Add friend sends friend request
* Accept friend request adds user to friend’s list and your list
* Deny friend request removes the friend request
* Delete friend removes from your list and friend’s list
* Friend pages pull proper profile picture
* User UID mapped to username in database when account created
* Swiping down from settings updates the user profile from database
* See a friend’s liked movies on their profile
* Remove sample data from Users class

### Anna Norman (Release 25%, overall 23.5%)
* Add elements to watchlist (list) screen
* Add elements to and did the formatting for the settings screen
* Create readme
* Format/Design/Constraints across screens in the storyboard
* Added icons on the tab bar
* Add scrolling to the movie page
---
* Pull API movie info for search 
* Pull user info from database and pictures from storage 
* Implemented search algorithms
* Store images in a cache for movie search to load faster 
* Create movie object from MovieDB init, and send user object on segue

## Deviations:
* Friends has not been implemented yet in the movie swiping the page, this means it shows that 0 friends instead of the actual number that have liked it, but this feature of friends list functionality hasn’t been implemented yet. 
* We did not implement the functionality of the privacy settings even when they’re updated, you shouldn’t be able to see a private profile if you’re not friends with them, but we hadn’t thought of this in the planning document and now we’re adding it as a task. 
* You cannot change your username yet from the settings, even though we said all the settings would be implemented. It works but will cause bugs because the database uses the username as a key in several places. We will fix this in the final release by using the UID instead of the username as a key.
* The “Add Friend” or “Unfriend” button in the Friend Profile page might be unclear to a user because it does not take into account the friend request paradigm. If there is a friend request, but the other user has denied or not accepted, then the button text does not make that clear. This will be fixed in the next release by adding more cases to the friend state and changing the wording of the button to be more clear to the user.
