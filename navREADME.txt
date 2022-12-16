Flash MDP Project Navigation README:

This is a short explanation file containing the instructions for running and altering the navigation algorithm of our app. At a high level, the navigation runs by doing Floyd Warshall to select the optimal elevator, a Breadth-First Search from the starting location to the chosen elevator, and then another BFS from the elevator to your car on the final level. 

The navigation is structured as follows:

There is a Nav class that sets up an internal mapping of a garage. In main, use the initiMap, setMapPoint, and setMapRange functions to create your map with the requisite characters:
S: Starting Position
C: Car Position
P: Parking Space
X: Wall
E: Elevator. : Empty Space

When the map is complete, run navigateRegular and then printNavOutput to obtain the path. 

navigateRegular works as follows:
If the start or end position isn't set, it returns an error. 
If the start and end position are on the same floor, just BFS to them (runs nav2d function)
If not, then Choose the best elevator using the findBestVert function, navigate to it, and then navigate from it to the car. 

Floyd Warshall elevator selection works by calculating the distance from the starting position to each elevator, from that elevator to the ending position, and then selecting the elevator that achieved the lowest total distance of the two.

Breadth First Search navigation works as follows:
You create a search queue (in this case deque, but logically identical here) that takes in Coordinates. You then add the starting position to the queue. Then, while the search container is not empty, you take the front element of the queue, check the Tiles in each direction of it, and add them to the back of the queue if they haven't been marked as previously discovered. As you add them in, mark them as discovered, and mark the direction taken to reach that tile into reachedByGoing. Repeat this until you've reached your destination.
To obtain the path, the backtrace through the "reachedByGoing" of each Tile from the elevator, reversing directions until the start. For example, if the elevator was reached by going north, we want to go south to backtrace. 

And that's the algorithm! This was created by Avraham Mikhli (amikhli@umich.edu), feel free to reach out with any questions!