// Device code:
// Deep sleep for INTERVAL seconds, read the sensor and report 
// the temp and humidity values to the agent.
//
// (C) 2020, Venky Raju
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

const INTERVAL = 30; // time between readings in seconds
const SPICLK = 937.5;

@include "DHT22"

function read_sensor() {
    
    // The DHT semsor reports incorrect readings if you read it rightaway.
    imp.sleep(3);

    local data = dht22.read();
    local temp = data.temp * 9.0/5 + 32;
    server.log(format("Relative Humidity: %0.1f",data.rh)+" %");
    server.log(format("Temperature: %0.1f F",temp));
    
    local weather = 
    {
        temp = temp,
        rh = data.rh
    }

    // Once the table is constructed, send it out to the agent with "impValues"
    // as the identifier.
    agent.send("impValues", weather);
}

imp.setpowersave(true);

imp.onidle(function(){
    server.sleepfor(INTERVAL);
});

spi         <- hardware.spi257;
clkspeed    <- spi.configure(MSB_FIRST, SPICLK);
dht22 <- DHT22(spi, clkspeed);

read_sensor();