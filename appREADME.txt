Flash MDP Project IOS Development README:

This file will contain the state of the application, how to use the app as it stands(to avoid any of the UI bugs :( ) , and what needs to be done moving forward! 

Current State:
	As of right now, the application is pretty bare bones in the grander scheme of things. It currently contains the first design the UI/UX team created, it has the navigation code embedded within it which is how the "user" image gets traversed throughout the map, and it has areas in the source code designated for localization calls. It essentially can serve as a good stepping stone for continual development as the navigation and localization components of the application are in good shape. We had a multitude of issues trying to test within a real garage, so most of this application was tested on a simulator. As such, the "LocationManager" and "Beacon Region" code is untested and essentially just hard-coded example code. That is about everything at a high level!

How to use the app:
	1. When the application opens up, select "Mark My Car"
	2. On the next page, you will see the map on purposely filled with a bunch of "X" images. This was to simulate needing to press the "Try Again" button to "relocalize". Press the "Try Again" button.
	3. After the spinning wheel disappears, you may input numbers into the 2 sections in the scrollable lists. Afterward, hit "Confirm".
	4. Next, hit "Find My Car".
	5. At this point, you can watch the simulation of a user moving throughout the garage with certain images dictating certain parts of the garage. The settings button in the upper right will pop open a side menu (toggle don't do anything), and can be dismissed by just tapping the shaded area on the right. 
	6. That's it! 

What needs to be done:
	1. UI/UX
		First of all, there exist UI bugs with the current design, however, this doesn't matter too much. The UI needs to be completely overhauled to match the current design given by the UI/UX team (Should be in the google doc filled with the links). This should get rid of all of the current constraint bugs that currently exist as well as make the application look way nicer :)
	2. Localization Incorporation
		The localization functions, algorithms, ML models, and everything else needs to be incorporated into the application itself. As briefly mentioned earlier, there should be comments in the code that dictate where localization calls occur, but just to go over it in case this isn't the case.
		i. There needs to be a call when "Mark My Car" is pressed. This should be ran asynchronously from the main thread, and after getting this information from the localization algorithm, open the next page and display the level of the map where the user is on.
		ii. There needs to be on when the user hits "Try Again". This will refresh the page essentially if the map is messed up upon observation from the user. 
		iii. There needs to be one if the user hits back from the page where the navigation part occurs (page 3). This will also update the map in case the user backs out from navigating.
	3. Add Navigation Algorithm Calls
		The navigation function (explained in the navREADME.txt file) should be called in correct places of the application as well. Similar to localization in terms of format, here are the areas where that should happen!
		i. When the user hits "Find My Car" after the user has determined the localization is correct. This will allow the next page to function properly.
		ii. When the user hits the "Try Again" button. This is needed to refresh the "userLocation" in the source code which makes the next page function properly.
	4. Source Code Refactor/Maintainability
		There are quite a few code style errors which may make the code less readable and harder to maintain. Most of these exist as a result of committing to this project to learn and the mistakes and sloppy code sort of expose that intention :) This should be addressed as well.

For information about the navigation, address the navREADME.txt file. Go to the google docs sent with all of the links to get information on the localization. 

Good luck and happy coding!
This was created by Samuel Bohnett (onefrfry@umich.edu), feel free to reach out with any questions!