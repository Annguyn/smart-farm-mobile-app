import 'dart:math';

double degToRad(num deg) => deg * (pi / 180.0);

double normalize(value, min, max) => ((value - min) / (max - min));

double angleRange(value, min, max)=>(value * (max-min) +min);

const double kDiameter = 200;
const double kMinDegree = 16;
const double kMaxDegree = 30;
const double kMinTemperature = 0.0;
const double kMaxTemperature = 50.0;
const double kMinHumidity = 0.0;
const double kMaxHumidity = 100.0;
const double kMinSoilMoisture = 0.0;
const double kMaxSoilMoisture = 4095.0;
const double kMaxDegreeTemperature = 40.0; // Adjust for temperature sensor
const double kMaxDegreeHumidity = 100.0; // Humidity
const double kMaxDegreeSoilMoisture = 4095.0; // Soil moisture
const double kMaxDegreeLightSensor = 4095.0; // Light sensor range (adjust as needed)
const double kMinDistance = 0.0; // Minimum distance (cm)
const double kMaxDistance = 25.0; // Maximum distance (cm)