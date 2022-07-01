#include <Stepper.h>
#include <Wire.h>
#include <EEPROM.h> //Needed to record user settings

#include "SparkFun_Qwiic_Scale_NAU7802_Arduino_Library.h" // Click here to get the library: http://librarymanager/All#SparkFun_NAU8702

NAU7802 myScale; //Create instance of the NAU7802 class

//EEPROM locations to store 4-byte variables
#define LOCATION_CALIBRATION_FACTOR 0 //Float, requires 4 bytes of EEPROM
#define LOCATION_ZERO_OFFSET 10 //Must be more than 4 away from previous spot. Long, requires 4 bytes of EEPROM

bool settingsDetected = false; //Used to prompt user to calibrate their scale

//Create an array to take average of weights. This helps smooth out jitter.
#define AVG_SIZE 4 //sets value of 4 weights to be averaged
float avgWeights[AVG_SIZE];
byte avgWeightSpot = 0;
long zeroOffset = myScale.getZeroOffset();
float calibrationFactor = myScale.getCalibrationFactor();

long currentReading = 0;
float currentWeightkg = 0;
float currentWeightN = 0;


//MOTOR SETTINGS
int StepsPerRevolution = 200;
int rpm = 1200; //Set by analysis done in calibration

Stepper stepper1(StepsPerRevolution, 3, 2);
Stepper stepper2(StepsPerRevolution, 5, 4);


//Function variables
const int numChar = 9;      // the number of characters we want to receive
char receivedChar[numChar]; // the array for received data
boolean newData = false;    // the indicator for new data, when new data arrives and receivedChar is filled, newData=true;

int func = 0;                // movement direction
int iLoad = 0;           // the number of steps
int iRate = 0;
int iPause = 0;
char endMarker = '>';       // the end marker character


//EXPERIMENTAL AND DATA ENTRY VARIABLES
int steps;

int pitch = .002;           //Need to find actual pitch of power screw
int microStepFrac = 4;      //Currently microstepping .25 steps
int stepsPerRotation = 800; //Actual steps per rotation with microstepping
unsigned long delayStart;

void setup()
{
  Serial.begin(115200);
  Serial.println("Qwiic Scale Example");

  pinMode(8, OUTPUT);
  pinMode(7, OUTPUT);

  Wire.begin();
  Wire.setClock(400000); //Qwiic Scale is capable of running at 400kHz if desired

  if (myScale.begin() == false)
  {
    Serial.println("Scale not detected. Please check wiring. Freezing...");
    while (1);
  }
  Serial.println("Scale detected!");

  readSystemSettings(); //Load zeroOffset and calibrationFactor from EEPROM

  myScale.setSampleRate(NAU7802_SPS_320); //Increase to max sample rate
  myScale.calibrateAFE(); //Re-cal analog front end when we change gain, sample rate, or channel

  myScale.calibrateAFE(); //Does an internal calibration. Recommended after power up, gain changes, sample rate changes, or channel changes.
}


void loop()
{
  if (Serial.available() > 0) // If something appears on the serial port, run this
  {
    record();             // fill in the array receivedChar
    execute();            // set the variables "dir" and "distance", here you can enter your code for driving the stepper motor
    //sendBack();           // this is to confirm that the code is running properly, we send back to MATLAB (or to an Arduino Serial monitor) what was received
  }
}

void record()
{
  static int index = 0; // this is the index for filling in "receivedChar", this variable does not need to be static, it can be a global variable...
  char rChar;   // received character, that is an output of Serial.read() function

  while (Serial.available() > 0 && newData == false)
  {
    rChar = Serial.read();
    delay(2);
    if (rChar != endMarker && index <= 8)
    {
      receivedChar[index] = rChar;
      index++;
    }
    else
    {
      receivedChar[index] = '\0'; // terminate the string at position 8
      index = 0;                 // reset the counter
      newData = true;            // set the "newData" indicator to true, meaning that the new data has arrived, and we can proceed further
    }
  }
}

void execute()
{
  // these two arrays are needed for the "atoi" function
  char tmpFunc[2];   // this one stores the direction
  char tmpLoad[4]; // this one stores the number of steps
  char tmpRate[4];
  char tmpPause[3];


  if (newData == true)
  {
    tmpFunc[0] = receivedChar[0];
    tmpFunc[1] = '\0'; //terminates string
    func = atoi(tmpFunc); //converts string to an integer,

    for (int j = 0; j <= 2; j++)
    {
      tmpLoad[j] = receivedChar[j + 1]; //finds the value at position 1 onward in recieved character string
    }
    tmpLoad[3] = '\0'; //termiates string
    iLoad = atoi(tmpLoad);

    for (int j = 0; j <= 2; j++)
    {
      tmpRate[j] = receivedChar[j + 4]; //finds the value at position 4 onward in recieved character string
    }
    tmpRate[3] = '\0'; //termiates string
    iRate = atoi(tmpRate);

    for (int j = 0; j <= 1; j++)
    {
      tmpPause[j] = receivedChar[j + 7]; //finds the value at position 1 onward in recieved character string
    }
    tmpPause[2] = '\0'; //termiates string
    iPause = atoi(tmpPause);

    delay(1);
    newData = false;

    // to free the buffer  (is something is still there)
    while (Serial.available() > 0)
    {
      Serial.read();
    }
  }

  if (func == 1) {
    jogIn(iLoad);
  }
  else if (func == 2) {
    jogOut(iLoad);
  }
  else if (func == 3) {
    preLoad(iLoad);
  }
  else if (func == 4) {
    limitSwitch();
  }
  else if (func == 5) {
    experiment(iLoad, iRate, iPause);
  }
  else if (func == 6) {
    jogLeft(iLoad);
  }
  else if (func == 7) {
    jogRight(iLoad);
  }

}

void sendBack()
{

  Serial.print(iLoad); // send back the distance, the number can be read from the Serial Monitor, or from MATLAB
  //Serial.println(dir); // send back the direction, the number can be read from the Serial Monitor, or from MATLAB
  Serial.write('\r');    // this is the 'CR' terminator for MATLAB, see the MATLAB code
}


long weightToScale(double x) {
  double weightN = x; //In Newtons
  double weightkg = weightN * 98.0665;
  long onScale = (weightkg * 461.42) - 24822;
  return (onScale);
}

double scaleToWeight(long x) {
  long onScale = x;
  double weightkg = ((onScale + 24822) / (461.43));
  double weightN = weightkg / 98.0665;
  return (weightN); // In Newtons
}


//Reads the current system settings from EEPROM
//If anything looks weird, reset setting to default value
void readSystemSettings(void)
{
  float settingCalibrationFactor; //Value used to convert the load cell reading to lbs or kg
  long settingZeroOffset; //Zero value that is found when scale is tared

  //Look up the calibration factor
  EEPROM.get(LOCATION_CALIBRATION_FACTOR, settingCalibrationFactor);
  if (settingCalibrationFactor == 0xFFFFFFFF)
  {
    settingCalibrationFactor = 0; //Default to 0
    EEPROM.put(LOCATION_CALIBRATION_FACTOR, settingCalibrationFactor);
  }

  //Look up the zero tare point
  EEPROM.get(LOCATION_ZERO_OFFSET, settingZeroOffset);
  if (settingZeroOffset == 0xFFFFFFFF)
  {
    settingZeroOffset = 1000L; //Default to 1000 so we don't get inf
    EEPROM.put(LOCATION_ZERO_OFFSET, settingZeroOffset);
  }

  //Pass these values to the library
  myScale.setCalibrationFactor(settingCalibrationFactor);
  myScale.setZeroOffset(settingZeroOffset);

  settingsDetected = true; //Assume for the moment that there are good cal values
  if (settingCalibrationFactor < 0.1 || settingZeroOffset == 1000)
    settingsDetected = false; //Defaults detected. Prompt user to cal scale.
}


///////////////////// FUNCTIONS TO RUN /////////////////////////////////////////////////////////////////

//(1) Pre Load
void preLoad(int x) {

  float preLoadN = x / 10.0;
  long preLoadR = 21321; //scaleToWeight(preLoadN); currently calulated by hand for 1 N

  Serial.print("Zero Offset: ");
  Serial.println(zeroOffset);
  Serial.print("  Calibration Factor: ");
  Serial.println(calibrationFactor);

  currentReading = myScale.getReading();
  //currentWeightN = scaleToWeight(currentReading);

  stepper1.setSpeed(300);
  stepper2.setSpeed(300);

  while (currentReading < preLoadR) {
    stepper1.step(-5);
    stepper2.step(-5);
    currentReading = myScale.getReading();
  }
  Serial.print("1000000,0\n");
}


//(2) Jog In
void jogIn(int x) {

  int dist = x; //In mm
  int distSteps = x * 200;
  
  stepper1.setSpeed(300);
  stepper2.setSpeed(300);

  for (int s = 0; s < distSteps; s++) {
    stepper1.step(-1);
    stepper2.step(-1);
  }
  Serial.print("1000000,0\n");
}



//(3) Jog Out
void jogOut(int x){

  int dist = x; //In mm
  int distSteps = x * 200;

  stepper1.setSpeed(300);
  stepper2.setSpeed(300);

  for (int s = 0; s < distSteps; s++) {
    stepper1.step(1);
    stepper2.step(1);
  }
  Serial.print("1000000,0\n");
}

//(4) Motor Home Position Calibration
void limitSwitch() {

  Serial.println("Limit Switch chosen");
  //Serial.write('\r');

  stepper1.setSpeed(500);
  stepper2.setSpeed(500);

  while (digitalRead(7) == HIGH) {
    stepper1.step(1);
  }
  while (digitalRead(8) == HIGH) {
    stepper2.step(1);
  }
  for (int s = 0; s < 1200; s++) {
    stepper1.step(-1);
    stepper2.step(-1);
  }
  Serial.print("1000000,0\n");
}



//(5) Experiment
void experiment(int x, int y, int z) {

  // Setting variables from input data
  double maxLoad = x / 10.0;          //In N (need to figure out having decimal places)
  double motorSpeed = y;           //In rpm (at some point need to figure out ability to have as N/s)
  long loadPause = z * 1000;        //In mS

  long maxReading = weightToScale(maxLoad);
  steps = 0;
  //float stepDelay;        //Calculated to change motor speed from delay inbetween steps (from scr code)
  delayStart = 0;       //start time of the delay between load and unload
  float preLoadR = weightToScale(1.0);

  //Get first reading
  currentReading = myScale.getReading();

  stepper1.setSpeed(motorSpeed);
  stepper2.setSpeed(motorSpeed);

  //Delay between steps in mS
  //stepDelay = (60L * 1000L) / (stepsPerRotation * motorSpeed);
  long k = 0;
  while (currentReading < maxReading) {
    k++;
    stepper1.step(-2);
    stepper2.step(-2);
    steps = steps + 4;
    currentReading = myScale.getReading();
    if (k == 3){
      Serial.print(currentReading);
      Serial.print(",");
      Serial.print(steps);
      Serial.print("\n");
      k = 0;
    }
  }
  
  delayStart = millis();
  k = 0;
  while ((millis() - delayStart) < loadPause) {
    k++;
    currentReading = myScale.getReading();
    if (k == 400){
      Serial.print(currentReading);
      Serial.print(",");
      Serial.print(steps);
      Serial.print("\n");
      k = 0;
    }

  }

  currentReading = myScale.getReading();
  k = 0;
  while (currentReading > preLoadR) {
    k++;
    stepper1.step(2);
    stepper2.step(2);
    steps = steps - 4;
    currentReading = myScale.getReading();
    if (k == 3){
      Serial.print(currentReading);
      Serial.print(",");
      Serial.print(steps);
      Serial.print("\n");
      k = 0;
    }
  }
  delay(300);
  Serial.print("1000000,0\n");
}

//(6) Jog Left
void jogLeft(int x)
{
  int dist = x; //In mm
  int distSteps = x * 200;

  stepper1.setSpeed(300);
  stepper2.setSpeed(300);

  for (int s = 0; s < distSteps; s++) {
    stepper1.step(-1);
    stepper2.step(1);
  }
  Serial.print("1000000,0\n");
}

//(7) Jog Right
void jogRight(int x)
{
  int dist = x; //In mm
  int distSteps = x * 200;

  stepper1.setSpeed(300);
  stepper2.setSpeed(300);

  for (int s = 0; s < distSteps; s++) {
    stepper1.step(1);
    stepper2.step(-1);
  }
  Serial.print("1000000,0\n");
}
