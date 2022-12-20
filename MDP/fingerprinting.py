from re import S
import numpy as np
import sklearn as skl
import csv
from pandas import read_csv
from sklearn.neighbors import KNeighborsClassifier
from sklearn.neighbors import KNeighborsRegressor
from sklearn.svm import LinearSVC
from sklearn.linear_model import SGDClassifier


#TODO: Implement other models, like SGD and RNN
#TODO: Pivot from single-point localization into path localization
#TODO: add headers into csv file and not only dataframe

#####* LOCALIZER CLASS *#####
class Localizer():
    """Localization class"""
    # Working on single point classification right now, will start on full path localization soon with the phone app, including path vector and accelerometer

    def __init__(self, n, x, y):
        """K nearest neighbors classification. Uses avg RSSI values and stdev as x (input), and (X,Y) coordinate as y (label)."""
        # Parameters
        self.num_beacons = n
        self.x_dim = x
        self.y_dim = y

        # K-Nearest Neighbors Regressor (Multi-Output)
        self.KNN_reg = KNeighborsRegressor(n_neighbors=n, weights='distance', algorithm='auto')
        # K-Nearest Neighbors Classifier (Multi-Output)
        self.KNN_class = KNeighborsClassifier(n_neighbors=n, weights='distance', algorithm='auto')

        # Support Vector Machine Classifier
        self.SVC_model = LinearSVC(penalty='l2', loss='squared_hinge', multi_class='ovr')
        # Stochastic Gradient Descent Classifier
        self.SGD_model = SGDClassifier(penalty='l2', loss='hinge')

        #TODO: Recurrent Neural Network Classifier

        # Container with all of user's positions
        self.positions = np.array([[-1.,-1.]])

        # Creating headers for CSV files
        self.headers = np.array(['X', 'Y'])
        for i in range(self.num_beacons):
            self.headers = np.append(self.headers, ('Beacon ' + str(i)))

        return

    def clear_data(self):
        """Clears current data in training and testing files - only run if remapping!"""
        with open('training_rps.csv', 'a+') as fh:
            fh.truncate(0)
        with open('testing_rps.csv', 'a+') as fh:
            fh.truncate(0)
        return

    def get_reading(self, filename):
        """Processes RSSI values from beacons and inserts default values if necessary."""
        # Get reading or manually input for now, including x y coordinates
        # Potential: average multiple readings to get average RSSI values, include avg + stdev
        RSSI_vals = np.empty(self.num_beacons)
        x = input("X-coord: ")
        y = input("Y-coord: ")
        for i in range(self.num_beacons):
            RSSI_vals[i] = (input("Beacon " + str(i) + ": "))

        #TODO: INSERT DEFAULT VALUES ONCE CONNECTED TO PHONE READING
        with open(filename, 'a', newline='') as csvfile:
            csvwriter = csv.writer(csvfile, delimiter=',',
                            quotechar='|', quoting=csv.QUOTE_MINIMAL)
            vals = np.array([x, y])
            vals = np.append(vals, RSSI_vals)
            csvwriter.writerow(vals)

        return

    def populate_training_data(self):
        """Populates dataset based on RSSI reading."""
        # Beacon manufacturing specifications, Apple SDK
        # Functions on App side will post recorded data to a CSV file, can upload to database and read into this program
        # Can also call get_reading() to record to CSV

        for x in range(self.x_dim):
            for y in range(self.y_dim):
                self.get_reading('training_rps.csv')

        df = read_csv('training_rps.csv', names=self.headers)
        print('\nTraining Data:')
        print(df)
        print('\n')

        return

    def populate_testing_data(self, x_test, y_test):
        """Populates testing data based on RSSI reading."""
        self.x_test_dim = x_test
        self.y_test_dim = y_test
        # Beacon manufacturing specifications, Apple SDK

        # Potential: record multiple readings to get average RSSI values
        # Insert default values if needed
        # Calculate avg and stdev

        for x in range(self.x_test_dim):
            for y in range(self.y_test_dim):
                self.get_reading('testing_rps.csv')
        return

    def train_model(self):
        """Separates dataset into inputs and labels, trains KNN model."""
        # Receive data from csv file/server      
        # Read data into pandas dataframe
        df = read_csv('training_rps.csv', names=self.headers)

        # Extracting features from dataframe
        self.X_train = df.drop(['X', 'Y'], axis=1)
        self.X_train = self.X_train.to_numpy()
        
        print("Training on features:")
        print(self.X_train)

        # Extracting labels from dataframe
        #self.y_train = [(str(row['X']) + ' ' + str(row['Y'])) for index,row in df.iterrows()]
        self.y_train = np.array([(np.array([row['X'], row['Y']])) for index,row in df.iterrows()])
        #self.y_train = self.y_train.flatten()

        print("True Labels:")
        print(self.y_train)
        print("\n")

        # Training model
        self.KNN_reg.fit(self.X_train, self.y_train)
        self.KNN_class.fit(self.X_train, self.y_train)
        #self.SVC_model.fit(self.X_train, self.y_train)
        #self.SGD_model.fit(self.X_train, self.y_train)
        return

    def test_model(self):
        """Runs predictions on testing dataset."""
        # Receive data from csv file/server
        df = read_csv('testing_rps.csv', names=self.headers)

        # Extracting features from dataframe
        X_test = df.drop(['X', 'Y'], axis=1)
        X_test = X_test.to_numpy()
        
        print("Testing on features:")
        print(X_test)

        # Extracting labels from dataframe
        #y_test = [(str(row['X']) + ' ' + str(row['Y'])) for index,row in df.iterrows()]
        y_test = np.array([(np.array([row['X'], row['Y']])) for index,row in df.iterrows()])
        print("True labels:")
        print(y_test)
        print('\n')

        # Predicting labels using trained model
        self.predict_loc(X_test)
        #print("Expected:")
        #print(y_test)
        #print("Predicted:")
        #print(y_pred)

        #print(self.KNN_model.score(self.X_test, self.y_test))
        return

    def live_model(self):
        """Function to receive one new, current RSSI value and localize."""
        # Receive current RSSI input (manually or from iPhone app)
        RSSI_str = input("Enter RSSI values for all " + str(self.num_beacons) + " beacons:")
        RSSI = [np.float64(val) for val in RSSI_str.split()]
        RSSI = np.reshape(RSSI, (1, -1))

        # Localize user with single new RSSI value
        self.predict_loc(RSSI)

        return

    def predict_loc(self, RSSIs):
        """Localize position based on current RSSI and other optimizations, add to position container."""
        # Use model to predict location
        #pred_locs = self.KNN_reg.predict(RSSIs)
        pred_locs = self.KNN_class.predict(RSSIs)

        for loc in pred_locs:
            #TODO: Calculate estimated current position using new prediction and other techniques/constraints (smoothing new prediction, prev. positions, accelerometer, etc.)

            # Add estimated location to position container
            self.positions = np.append(self.positions, np.array([loc]), axis=0)

        return


#####* MAIN FUNCTION *#####
localizer = Localizer(3, 1, 3)
#localizer.clear_data()
print("Training Model...\n")
#localizer.training_data()
localizer.train_model()
print("Testing Model...\n")
#localizer.testing_data(1,3)
localizer.test_model()

#localizer.live_model()
print("Final Path:")
print(localizer.positions)
