// Device code:
// Deep sleep for INTERVAL seconds, read the sensor and report 
// the temp and humidity values to the agent.
//
// (C) 2020, Venky Raju
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

const INTERVAL = 15; // time between readings in seconds

// From https://github.com/giordanofabbri/Bosch-BME280-Electric-Imp-driver
// By giordanofabbri
// Thank you for sharing!!!
@include "BME280.nut"

// We use a balanced voltage divider at the imp to 
// measure half the battery voltage
// Vcc = 3.286, multiplier = Vcc/32767
const VOLTAGE_MULTIPLIER = 0.0001;

// We are using pins 1,2 and 7 for battery measurement and charging status
batt_vltg_pin <- hardware.pin7;
batt_vltg_pin.configure(ANALOG_IN);

chrg_sts_pin <- hardware.pin1;
chrg_sts_pin.configure(DIGITAL_IN_PULLUP);

chrg_com_pin <- hardware.pin2;
chrg_com_pin.configure(DIGITAL_IN_PULLUP);

function read_sensor() {

 //   local temp, pressure, humidity;
 //   local voltage, charging_status, charging_com;
    
    local i2c = hardware.i2c89;
    i2c.configure(CLOCK_SPEED_10_KHZ);
    local bme280 = BME280(i2c, 0x76);
    bme280.init();
    bme280.SetSamplingMode();
    bme280.WaitForMeasureCompleted();
    
    local temp = bme280.readTemperature();
    temp = temp * 9.0 / 5 + 32;
    local pressure = bme280.readPressure();
    local humidity = bme280.readHumidity();
    local voltage = batt_vltg_pin.read() * VOLTAGE_MULTIPLIER;
    local charging_status = chrg_sts_pin.read();
    local charging_com = chrg_com_pin.read();

    server.log(format("%0.1f F, %0.1f %%, %0.0f Pa", temp, humidity, pressure));
    server.log(format("%0.2f V, %d:%d", voltage, charging_status, charging_com));

    local data = 
    {
        T = temp,
        H = humidity,
        P = pressure,
        V = voltage,
        C = charging_status,
        D = charging_com
    }

    agent.send("weatherImpData", data);
}

imp.setpowersave(true);

imp.onidle(function(){
    server.sleepfor(INTERVAL);
});

read_sensor();

