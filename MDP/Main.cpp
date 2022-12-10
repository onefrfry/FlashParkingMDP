#include <iostream>
#include <algorithm>
#include <vector>
#include "testNav.cpp"


using namespace std;

int main() {
	// This should be in all of your projects, speeds up I/O
	ios_base::sync_with_stdio(false);


	//Floor concept:
	//E E P P P P P P P P P E E
	//E E P P P P P P P P C E E
	//. . . . . . . . . . . . . 
	//P P . . P P X P P . . P P 
	//P P . . P P X P P . . P P 
	//P P . . P P X P P . . P P 
	//P P . . P P X P P . . P P 
	//P P . . P P X P P . . P P 
	//P P . . P P X P P . . P P 
	//P P . . P P X P P . . P P 
	//P P . . P P X P P . . P P 
	//P P . . P P X P P . . P P 
	//. . . . . . . S . . . . .
	//E E P P P P P P P P P E E
	//E E P P P P P P P P P E E
	Nav testGarage;
	testGarage.initMap(3, 13, 13); //figure out what to do for z here
	testGarage.setMapRange(0, 0, 1, 0, 1, 'E');
	testGarage.setMapRange(0, 0, 1, 11, 12, 'E');
	testGarage.setMapRange(0, 11, 12, 0, 1, 'E');
	testGarage.setMapRange(0, 11, 12, 11, 12, 'E');
	testGarage.setMapRange(0, 2, 10, 0, 1, 'P');
	testGarage.setMapRange(0, 2, 10, 11, 12, 'P');
	testGarage.setMapRange(0, 0, 1, 3, 9, 'P');
	testGarage.setMapRange(0, 11, 12, 3, 9, 'P');
	testGarage.setMapRange(0, 4, 5, 3, 9, 'P');
	testGarage.setMapRange(0, 7, 8, 3, 9, 'P');
	testGarage.setMapRange(0, 6, 6, 3, 9, 'X');
	testGarage.setMapRange(1, 2, 10, 0, 1, 'P');
	testGarage.setMapRange(1, 2, 10, 11, 12, 'P');
	testGarage.setMapRange(1, 0, 1, 3, 9, 'P');
	testGarage.setMapRange(1, 11, 12, 3, 9, 'P');
	testGarage.setMapRange(1, 4, 5, 3, 9, 'P');
	testGarage.setMapRange(1, 7, 8, 3, 9, 'P');
	testGarage.setMapRange(1, 6, 6, 3, 9, 'X');
	testGarage.setMapRange(2, 2, 10, 0, 1, 'P');
	testGarage.setMapRange(2, 2, 10, 11, 12, 'P');
	testGarage.setMapRange(2, 0, 1, 3, 9, 'P');
	testGarage.setMapRange(2, 11, 12, 3, 9, 'P');
	testGarage.setMapRange(2, 4, 5, 3, 9, 'P');
	testGarage.setMapRange(2, 7, 8, 3, 9, 'P');
	testGarage.setMapRange(2, 6, 6, 3, 9, 'X');
	testGarage.setMapPoint(0, 7, 10, 'S');
	//testGarage.setMapPoint(0, 10, 1, 'C');
	//testGarage.setMapPoint(0, 10, 1, 'P');
	testGarage.setMapPoint(2, 9, 1, 'C');	
	testGarage.navigateRegular();
	//testGarage.navigateVecField();
	testGarage.printNavOutput(); //broke for multilevel
	//testGarage.printVecField();

	//testGarage.findBestVert();
	//testGarage.printNavMap();
	return 0;
}