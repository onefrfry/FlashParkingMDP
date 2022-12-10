#include <stdio.h>
#include "testNav.hpp"


using namespace std;

//avg spot is 16-18 by 8-9, so lets say 16:8, so scale down to 2:1. A tile will represent 64 square feet
//if 2 nodes is a car, say 1 node is an elevator or staircase, l.;
//ideas for future optimizations in Dijkstra's: 
//		Add slight weight to turns so that it chooses a largely straight path
//		Add slight weight towards options that bring you further from the middle of the room, so it prefers to go down main routes

void Nav::initMap(int floors, int rows, int columns) {
    numRows = rows;
    numCols = columns;
    garage = vector< vector< vector<Tile> > >(floors, vector< vector<Tile> >(rows, vector<Tile>(columns, { '.', '.', 'x', 0 })));
}

int Nav::getFloor(int z) {
    //go through floor ranges to find a val
    for (int i = 0; i < zRanges.size(); ++i) {
        if (z > zRanges[i].first && z <= zRanges[i].second) { return i; }
    }
    cout << "did not map to any floor\n";
    return -1;
}

double Nav::getDistance(Coord a, Coord b) {
    return sqrt(pow(b.x - a.x, 2) + pow(b.y-a.y, 2));
}

void Nav::setMapRange(int z, int xMin, int xMax, int yMin, int yMax, char val) {
    //int floor = getFloor(z);
    int floor = z;
    switch (val) {
    case '.':
    case 'P':
    case 'X':
        for (int row = yMin; row <= yMax; ++row) {
            for (int col = xMin; col <= xMax; ++col) {
                garage[floor][row][col].value = val;
            }
        }
        break;
    case 'E':
        for (int row = yMin; row <= yMax; ++row) {
            for (int col = xMin; col <= xMax; ++col) {
                vert.emplace_back(Coord{ 0, row, col });
                for (int z = 0; z < garage.size(); ++z) {
                    garage[z][row][col].value = val;
                } //have to do z last here because of the emplacing
            }
        }
        break;
    case 'S':
        garage[floor][yMin][xMin].value = val;
        start = { floor, yMin, xMin };
        break;
    case 'C':
        garage[floor][yMin][xMin].value = val;
        end = { floor, yMin, xMin };
        break;
    default:
        cout << "invalid input\n";
        break;
    }
}

void Nav::setMapPoint(int z, int x, int y, char val) {
    setMapRange(z, x, x, y, y, val);
}

void Nav::printNavMap() {
    for (int z = 0; z < garage.size(); ++z) {
        for (int row = 0; row < garage[z].size(); ++row) {
            for (int col = 0; col < garage[z][row].size(); ++col) {
                cout << garage[z][row][col].value << " ";
            }
            cout << "\n";
        }
        cout << "\nFloor " << z << ":\n";
    }
}

void Nav::reset() {
    for (int z = 0; z < garage.size(); ++z) {
        for (int row = 0; row < garage[z].size(); ++row) {
            for (int col = 0; col < garage[z][row].size(); ++col) {
                garage[z][row][col].discovered = false;
                garage[z][row][col].reachedByGoing = '.';
                garage[z][row][col].directionToCar = 'x';
            }
        }
    }
    vector<Coord> empt;
    output = empt;
}

vector<Nav::Coord> Nav::navigateRegular() {
    //alg time!
    //setup is done
    //if start.z == end.z, 2d nav call
    //else
        //findBestVert
        //2d nav to it
        //2d nav to car
    //will have to track path taken somehow
    if (start.z == -1 || end.z == -1) {
        cout << "start and end position not set, cannot navigate\n";
        return output; //will just be empty
    }
    if (start.z == end.z) { nav2d(start, end); }
    else {
        Coord bestVert = findBestVert();
        bestVert.z = start.z;
        nav2d(start, bestVert);
        bestVert.z = end.z;
        nav2d(bestVert, end);
    }
    return output;
}

void Nav::nav2d(Coord start, Coord end) {
    // to do:
    // Dijkstra's method of keeping track of shortest way to each node, requires adding to the tile struct
    // to get to each node, need to use queue method from 281 p1, I think.
    // Look into other methods - A* or just BFS, since no weights
    // Start with BFS, move to A* later -
    //        practically, this means for now always check in every direction, instead of prioritizing directions closer to the goal
    //

    //BFS:
    // create deque, add start to it, mark start as found
    // while deque not empty:
    //        pop front -- move there (no need to set it to discovered since we can set that on entrance
    //        look NESW, do the following for each one if not discovered:
    //            make it discovered
    //            set the reachedByGoing
    //            if end, return backtrace()
    //            else if open space, add to queue

    deque<Coord> search;
    search.emplace_back(start);
    garage[start.z][start.y][start.x].discovered = true;
    while (!search.empty()) {
        Coord currCoord = search.front();
        Coord nextCoord;
        search.pop_front();
        //Tile& nextTile = garage[0][0][0]; //to not redeclare each time ***THIS DOESN'T WORK, CAN'T REASSIGN REFERENCES***
        if (currCoord.y > 0){ //Look North if not at the top
            nextCoord = currCoord;
            --nextCoord.y;
            Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
            if (!nextTile.discovered) {
                if (nextCoord == end) {
                    nextTile.reachedByGoing = 'n';
                    return backTrace(nextCoord);
                }
                if (nextTile.value == '.') {
                    nextTile.discovered = true;
                    nextTile.reachedByGoing = 'n';
                    search.emplace_back(nextCoord);
                }
            }
        } //North
        if (currCoord.x + 1 < numCols) { //Look East if not at the right
            nextCoord = currCoord;
            ++nextCoord.x;
            Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
            if (!nextTile.discovered) {
                if (nextCoord == end) {
                    nextTile.reachedByGoing = 'e';
                    return backTrace(nextCoord);
                }
                if (nextTile.value == '.') {
                    nextTile.discovered = true;
                    nextTile.reachedByGoing = 'e';
                    search.emplace_back(nextCoord);
                }
            }
        } //East
        if (currCoord.y + 1 < numRows) { //Look South if not at the bottom
            nextCoord = currCoord;
            ++nextCoord.y;
            Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
            if (!nextTile.discovered) {
                if (nextCoord == end) {
                    nextTile.reachedByGoing = 's';
                    return backTrace(nextCoord);
                }
                if (nextTile.value == '.') {
                    nextTile.discovered = true;
                    nextTile.reachedByGoing = 's';
                    search.emplace_back(nextCoord);
                }
            }
        } //South
        if (currCoord.x > 0) { //Look West if not at the left
            nextCoord = currCoord;
            --nextCoord.x;
            Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
            if (!nextTile.discovered) {
                if (nextCoord == end) {
                    nextTile.reachedByGoing = 'w';
                    return backTrace(nextCoord);
                }
                if (nextTile.value == '.') {
                    nextTile.discovered = true;
                    nextTile.reachedByGoing = 'w';
                    search.emplace_back(nextCoord);
                }
            }
        } //West
    }
}

void Nav::backTrace(Coord pos) {
    //walk back till it's a dot, since we don't set a reachedByGoing value for the first one
    //push back instructions to the output vector, push an end char when ur done
    output.emplace_back(pos);
    while (true) {
        switch (garage[pos.z][pos.y][pos.x].reachedByGoing) {
        case 'n': //go south
            ++pos.y;
            break;
        case 'e': //go west
            --pos.x;
            break;
        case 's': //go north
            --pos.y;
            break;
        case 'w': //go east
            ++pos.x;
            break;
        default:
            return;
        }
        output.emplace_back(pos);
    }
}

Nav::Coord Nav::findBestVert() {
    Coord minCoord = { 0,0,0 };
    double minDistance = INT_MAX;
    double tempDist;
    for (auto v : vert) {
        tempDist = getDistance(start, v) + getDistance(v, end);
        if (tempDist < minDistance) {
            minDistance = tempDist;
            minCoord = v;
        }
    }
    cout << "selected vert at (" << minCoord.x << ", " << minCoord.y << ")\n";
    return minCoord;
}

void Nav::printNavOutput() {
    //cout << "End: \n(X = " << end.x << ", Y = " << end.y << ", Z = " << end.z << ")\n";
    cout << "Path:\n";
    for (auto o : output) {
        cout << "(X = " << o.x << ", Y = " << o.y << ", Z = " << o.z << ")\n";
    }
    //cout << "Start: \n(X = " << start.x << ", Y = " << start.y << ", Z = " << start.z << ")\n";
}

vector<Nav::Coord> Nav::navigateVecField() {
    if (start.z == -1 || end.z == -1) {
        cout << "start and end position not set, cannot navigate\n";
        return output; //will just be empty
    }
    start.z == end.z ? fillVecField(end, -1) : fillVecField(end, end.z);
    vecNav(start);
    return output;
}

void Nav::fillVecField(Coord car, int nextFloor) {
    //literally just BFS from car
    deque<Coord> search;
    search.emplace_back(car);
    garage[car.z][car.y][car.x].discovered = true;
    while (!search.empty()) {
        Coord currCoord = search.front();
        Coord nextCoord;
        search.pop_front();
        //if its an elevator
        if (nextFloor != -1 && garage[currCoord.z][currCoord.y][currCoord.x].value == 'E') {
            nextCoord = currCoord;
            nextCoord.z = nextFloor;
            Tile & nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
            if (!nextTile.discovered) {
                if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
                    nextTile.discovered = true;
                    nextTile.directionToCar = '0' + car.z; //change if more than 10 floors
                    search.emplace_back(nextCoord);
                }
            }
        }
        if (currCoord.y > 0) { //Look North if not at the top
            nextCoord = currCoord;
            --nextCoord.y;
            Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
            if (!nextTile.discovered) {
                if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
                    nextTile.discovered = true;
                    nextTile.directionToCar = 's';
                    search.emplace_back(nextCoord);
                }
            }
        } //North
        if (currCoord.x + 1 < numCols) { //Look East if not at the right
            nextCoord = currCoord;
            ++nextCoord.x;
            Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
            if (!nextTile.discovered) {
                if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
                    nextTile.discovered = true;
                    nextTile.directionToCar = 'w';
                    search.emplace_back(nextCoord);
                }
            }
        } //East
        if (currCoord.y + 1 < numRows) { //Look South if not at the bottom
            nextCoord = currCoord;
            ++nextCoord.y;
            Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
            if (!nextTile.discovered) {
                if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
                    nextTile.discovered = true;
                    nextTile.directionToCar = 'n';
                    search.emplace_back(nextCoord);
                }
            }
        } //South
        if (currCoord.x > 0) { //Look West if not at the left
            nextCoord = currCoord;
            --nextCoord.x;
            Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
            if (!nextTile.discovered) {
                if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
                    nextTile.discovered = true;
                    nextTile.directionToCar = 'e';
                    search.emplace_back(nextCoord);
                }
            }
        } //West
    }
}

void Nav::vecNav(Coord loc) {
    Coord curCoord = loc;
    Tile curTile = garage[curCoord.z][curCoord.y][curCoord.x];
    while (curTile.value != 'C') {
        curTile = garage[curCoord.z][curCoord.y][curCoord.x];
        output.emplace_back(curCoord);
        switch (curTile.directionToCar) {
        case 'n':
            --curCoord.y;
            break;
        case 'e':
            ++curCoord.x;
            break;
        case 's':
            ++curCoord.y;
            break;
        case 'w':
            --curCoord.x;
            break;
        default:
            if (isdigit(curTile.directionToCar - '0')) {
                curCoord.z = curTile.directionToCar - '0';
            }
            else if (curTile.value == 'C'){}
            else { exit(1); }
            break;

        } //switch
    } //while
}

void Nav::printVecField() {
    //cout << "End: \n(X = " << end.x << ", Y = " << end.y << ", Z = " << end.z << ")\n";
    cout << "Vector Field:\n";
    for (int z = 0; z < garage.size(); ++z) {
        for (int row = 0; row < garage[z].size(); ++row) {
            for (int col = 0; col < garage[z][row].size(); ++col) {
                Tile nextTile = garage[z][row][col];
                if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
                    cout << nextTile.directionToCar << " ";
                }
                else {
                    cout << nextTile.value << " ";
                }
            }
            cout << endl;
        }
        cout << endl << endl;
    }
    //cout << "Start: \n(X = " << start.x << ", Y = " << start.y << ", Z = " << start.z << ")\n";
}
/*
 Dummy function that will probably be killed
 Will return the garage as is with all of its points
 */
vector<vector<vector<Nav::Tile>>> Nav::returnGarage() {
    return garage;
}

vector<Nav::Coord> Nav::returnOutput() {
    return output;
}

/*
class Nav {
private:
	struct Coord {
		//has to be ZXY, each element in the outer Z vector must have a 2D map on it. 
		int z; //floor
		int y; //row
		int x; //col
		friend bool operator== (const Coord& lhs, const Coord& rhs) {
			if (lhs.z == rhs.z && lhs.y == rhs.y && lhs.x == rhs.x) return true;
			else return false;
		};
	};
	//friend bool operator== (const Coord& lhs, const Coord& rhs) {
	//	if (lhs.z == rhs.z && lhs.y == rhs.y && lhs.x == rhs.x) return true;
	//	else return false;
	//};
	struct Tile {
		char value;			   // .SPECX
		char reachedByGoing;   // nesw
		char directionToCar; //nesw DUPLICATE OF reachedByGoing BC IM LAZY
		bool discovered;
	};

	int numRows;
	int numCols;
	Coord start = { -1, -1, -1 };
	Coord end = { -1, -1, -1 };
	vector<	vector<	vector<Tile> > > garage;

	//this is not necessary for checking whether you are in a vert zone -- just check the char
	//this is necessary for floyd warshall
	vector<Coord> vert;

	vector<Coord> output;
	//necessary for figuring out which floor a point is on
	vector< pair <int, int> >zRanges;
public:
	void initMap(int floors, int rows, int columns) { //floors columns rows
		numRows = rows;
		numCols = columns;
		garage = vector< vector< vector<Tile> > >(floors, vector< vector<Tile> >(rows, vector<Tile>(columns, { '.', '.', 'x', 0 })));
	}
	int getFloor(int z) {
		//go through floor ranges to find a val 
		for (int i = 0; i < zRanges.size(); ++i) {
			if (z > zRanges[i].first && z <= zRanges[i].second) { return i; }
		}
		cout << "did not map to any floor\n";
		return -1;
	}
	double getDistance(Coord a, Coord b) {
		return sqrt(pow(b.x - a.x, 2) + pow(b.y-a.y, 2));
	}
	//void setStart(int z, int x, int y) { start = { x,y,z }; }
	//void setEnd(int z, int x, int y) { end = { x,y,z }; }
	//void setCar(int z, int x, int y) { garage[x][y][z] = { 'C' }; }
	//void setVertical(int x, int y) { 
	//	garage[x][y][0] = { 'X' }; 
	//} //assuming verticals are same for each floor
	//void setParkingSpot(int z, int x, int y) { garage[x][y][z] = { 'P' }; }
	//void setWall(int z, int x, int y) { garage[x][y][z] = { 'X' }; }
	void setMapRange(int z, int xMin, int xMax, int yMin, int yMax, char val) {
		//int floor = getFloor(z);
		int floor = z;
		switch (val) {
		case '.':
		case 'P':
		case 'X':
			for (int row = yMin; row <= yMax; ++row) {
				for (int col = xMin; col <= xMax; ++col) {
					garage[floor][row][col].value = val;
				}
			}
			break;
		case 'E':
			for (int row = yMin; row <= yMax; ++row) {
				for (int col = xMin; col <= xMax; ++col) {
					vert.emplace_back(Coord{ 0, row, col });
					for (int z = 0; z < garage.size(); ++z) {
						garage[z][row][col].value = val;
					} //have to do z last here because of the emplacing
				}
			}
			break;
		case 'S':
			garage[floor][yMin][xMin].value = val;
			start = { floor, yMin, xMin };
			break;
		case 'C':
			garage[floor][yMin][xMin].value = val;
			end = { floor, yMin, xMin };
			break;
		default:
			cout << "invalid input\n";
			break;
		}
	}
	void setMapPoint(int z, int x, int y, char val) { setMapRange(z, x, x, y, y, val); }
	void printNavMap() {
		for (int z = 0; z < garage.size(); ++z) {
			for (int row = 0; row < garage[z].size(); ++row) {
				for (int col = 0; col < garage[z][row].size(); ++col) {
					cout << garage[z][row][col].value << " ";
				}
				cout << "\n";
			}
			cout << "\nFloor " << z << ":\n";
		}
	}
	void reset(){
		for (int z = 0; z < garage.size(); ++z) {
			for (int row = 0; row < garage[z].size(); ++row) {
				for (int col = 0; col < garage[z][row].size(); ++col) {
					garage[z][row][col].discovered = false;
					garage[z][row][col].reachedByGoing = '.';
					garage[z][row][col].directionToCar = 'x';
				}
			}
		}
		vector<Coord> empt;
		output = empt;
	}
	vector<Coord> navigateRegular() {
		//alg time!
		//setup is done
		//if start.z == end.z, 2d nav call
		//else
			//findBestVert
			//2d nav to it
			//2d nav to car
		//will have to track path taken somehow
		if (start.z == -1 || end.z == -1) {
			cout << "start and end position not set, cannot navigate\n";
			return output; //will just be empty
		}
		if (start.z == end.z) { nav2d(start, end); }
		else {
			Coord bestVert = findBestVert();
			bestVert.z = start.z;
			nav2d(start, bestVert);
			bestVert.z = end.z;
			nav2d(bestVert, end);
		}
		return output;
	}
	void nav2d(Coord start, Coord end) {
		// to do:
		// Dijkstra's method of keeping track of shortest way to each node, requires adding to the tile struct
		// to get to each node, need to use queue method from 281 p1, I think. 
		// Look into other methods - A* or just BFS, since no weights
		// Start with BFS, move to A* later - 
		//		practically, this means for now always check in every direction, instead of prioritizing directions closer to the goal
		//

		//BFS:
		// create deque, add start to it, mark start as found
		// while deque not empty:
		//		pop front -- move there (no need to set it to discovered since we can set that on entrance
		//		look NESW, do the following for each one if not discovered:
		//			make it discovered
		//			set the reachedByGoing
		//			if end, return backtrace()
		//			else if open space, add to queue

		deque<Coord> search;
		search.emplace_back(start);
		garage[start.z][start.y][start.x].discovered = true;
		while (!search.empty()) {
			Coord currCoord = search.front();
			Coord nextCoord;
			search.pop_front();
			//Tile& nextTile = garage[0][0][0]; //to not redeclare each time ***THIS DOESN'T WORK, CAN'T REASSIGN REFERENCES*** 
			if (currCoord.y > 0){ //Look North if not at the top
				nextCoord = currCoord;
				--nextCoord.y;
				Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
				if (!nextTile.discovered) {
					if (nextCoord == end) {
						nextTile.reachedByGoing = 'n';
						return backTrace(nextCoord);
					}
					if (nextTile.value == '.') {
						nextTile.discovered = true;
						nextTile.reachedByGoing = 'n';
						search.emplace_back(nextCoord);
					}
				}
			} //North
			if (currCoord.x + 1 < numCols) { //Look East if not at the right
				nextCoord = currCoord;
				++nextCoord.x;
				Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
				if (!nextTile.discovered) {
					if (nextCoord == end) {
						nextTile.reachedByGoing = 'e';
						return backTrace(nextCoord);
					}
					if (nextTile.value == '.') {
						nextTile.discovered = true;
						nextTile.reachedByGoing = 'e';
						search.emplace_back(nextCoord);
					}
				}
			} //East
			if (currCoord.y + 1 < numRows) { //Look South if not at the bottom
				nextCoord = currCoord;
				++nextCoord.y;
				Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
				if (!nextTile.discovered) {
					if (nextCoord == end) {
						nextTile.reachedByGoing = 's';
						return backTrace(nextCoord);
					}
					if (nextTile.value == '.') {
						nextTile.discovered = true;
						nextTile.reachedByGoing = 's';
						search.emplace_back(nextCoord);
					}
				}
			} //South
			if (currCoord.x > 0) { //Look West if not at the left
				nextCoord = currCoord;
				--nextCoord.x;
				Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
				if (!nextTile.discovered) {
					if (nextCoord == end) {
						nextTile.reachedByGoing = 'w';
						return backTrace(nextCoord);
					}
					if (nextTile.value == '.') {
						nextTile.discovered = true;
						nextTile.reachedByGoing = 'w';
						search.emplace_back(nextCoord);
					}
				}
			} //West
		}
	}
	void backTrace(Coord pos){
		//walk back till it's a dot, since we don't set a reachedByGoing value for the first one
		//push back instructions to the output vector, push an end char when ur done
		output.emplace_back(pos);
		while (true) {
			switch (garage[pos.z][pos.y][pos.x].reachedByGoing) {
			case 'n': //go south
				++pos.y;
				break;
			case 'e': //go west
				--pos.x;
				break;
			case 's': //go north
				--pos.y;
				break;
			case 'w': //go east
				++pos.x;
				break;
			default:
				return;
			}
			output.emplace_back(pos);
		}
	}
	Coord findBestVert() {
		Coord minCoord = { 0,0,0 };
		double minDistance = INT_MAX;
		double tempDist;
		for (auto v : vert) {
			tempDist = getDistance(start, v) + getDistance(v, end);
			if (tempDist < minDistance) {
				minDistance = tempDist;
				minCoord = v;
			}
		}
		cout << "selected vert at (" << minCoord.x << ", " << minCoord.y << ")\n";
		return minCoord;
	}
	void printNavOutput() {
		//cout << "End: \n(X = " << end.x << ", Y = " << end.y << ", Z = " << end.z << ")\n";
		cout << "Path:\n";
		for (auto o : output) {
			cout << "(X = " << o.x << ", Y = " << o.y << ", Z = " << o.z << ")\n";
		}
		//cout << "Start: \n(X = " << start.x << ", Y = " << start.y << ", Z = " << start.z << ")\n";
	}

	//vector field
	vector<Coord> navigateVecField() {
		if (start.z == -1 || end.z == -1) {
			cout << "start and end position not set, cannot navigate\n";
			return output; //will just be empty
		}
		start.z == end.z ? fillVecField(end, -1) : fillVecField(end, end.z);
		vecNav(start);
		return output;
	}
	//pass in a floor number to go to. -1 means no vertical movement necessary
	//we're assuming that even for renavigation, we wont need to go to other floors than the ones necessary
	//in the future, decide on implementing a flow for that error.
	void fillVecField(Coord car, int nextFloor) {
		//literally just BFS from car
		deque<Coord> search;
		search.emplace_back(car);
		garage[car.z][car.y][car.x].discovered = true;
		while (!search.empty()) {
			Coord currCoord = search.front();
			Coord nextCoord;
			search.pop_front();
			//if its an elevator
			if (nextFloor != -1 && garage[currCoord.z][currCoord.y][currCoord.x].value == 'E') {
				nextCoord = currCoord;
				nextCoord.z = nextFloor;
				Tile & nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
				if (!nextTile.discovered) {
					if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
						nextTile.discovered = true;
						nextTile.directionToCar = '0' + car.z; //change if more than 10 floors
						search.emplace_back(nextCoord);
					}
				}
			}
			if (currCoord.y > 0) { //Look North if not at the top
				nextCoord = currCoord;
				--nextCoord.y;
				Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
				if (!nextTile.discovered) {
					if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
						nextTile.discovered = true;
						nextTile.directionToCar = 's';
						search.emplace_back(nextCoord);
					}
				}
			} //North
			if (currCoord.x + 1 < numCols) { //Look East if not at the right
				nextCoord = currCoord;
				++nextCoord.x;
				Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
				if (!nextTile.discovered) {
					if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
						nextTile.discovered = true;
						nextTile.directionToCar = 'w';
						search.emplace_back(nextCoord);
					}
				}
			} //East
			if (currCoord.y + 1 < numRows) { //Look South if not at the bottom
				nextCoord = currCoord;
				++nextCoord.y;
				Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
				if (!nextTile.discovered) {
					if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
						nextTile.discovered = true;
						nextTile.directionToCar = 'n';
						search.emplace_back(nextCoord);
					}
				}
			} //South
			if (currCoord.x > 0) { //Look West if not at the left
				nextCoord = currCoord;
				--nextCoord.x;
				Tile& nextTile = garage[nextCoord.z][nextCoord.y][nextCoord.x]; //just for readability
				if (!nextTile.discovered) {
					if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
						nextTile.discovered = true;
						nextTile.directionToCar = 'e';
						search.emplace_back(nextCoord);
					}
				}
			} //West
		}
	}
	void vecNav(Coord loc){
		Coord curCoord = loc;
		Tile curTile = garage[curCoord.z][curCoord.y][curCoord.x];
		while (curTile.value != 'C') {
			curTile = garage[curCoord.z][curCoord.y][curCoord.x];
			output.emplace_back(curCoord);
			switch (curTile.directionToCar) {
			case 'n':
				--curCoord.y;
				break;
			case 'e':
				++curCoord.x;
				break;
			case 's':
				++curCoord.y;
				break;
			case 'w':
				--curCoord.x;
				break;
			default:
				if (isdigit(curTile.directionToCar - '0')) {
					curCoord.z = curTile.directionToCar - '0';
				}
				else if (curTile.value == 'C'){}
				else { exit(1); }
				break;

			} //switch
		} //while
	}
	void printVecField() {
		//cout << "End: \n(X = " << end.x << ", Y = " << end.y << ", Z = " << end.z << ")\n";
		cout << "Vector Field:\n";
		for (int z = 0; z < garage.size(); ++z) {
			for (int row = 0; row < garage[z].size(); ++row) {
				for (int col = 0; col < garage[z][row].size(); ++col) {
					Tile nextTile = garage[z][row][col];
					if (nextTile.value == '.' || nextTile.value == 'E' || nextTile.value == 'S') {
						cout << nextTile.directionToCar << " ";
					}
					else {
						cout << nextTile.value << " ";
					}
				}
				cout << endl;
			}
			cout << endl << endl;
		}
		//cout << "Start: \n(X = " << start.x << ", Y = " << start.y << ", Z = " << start.z << ")\n";
	}
}; //Nav
 */
