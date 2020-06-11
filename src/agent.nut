// Device code:
// Deep sleep for INTERVAL seconds, read the sensor and report 
// the temp and humidity values to the agent.
//
// (C) 2020, Venky Raju
// This file is licensed under the MIT License
// http://opensource.org/licenses/MIT

temp <- 0;
humidity <- 0;
presssure <- 0;
battery <- 0;
charging <- false;
charging_complete <- false;
last_checkin <- "Never";
utc_offset <- (-7*3600);   // in seconds

// Callback, provides JSON output to caller
function respondImpData(request,response){

    // First, construct a JSON table with our received pin values.
    local weather = {
        "temp": temp,
        "humidity": humidity,
        "pressure": presssure,
        "battery": battery,
        "charging": charging,
        "fully charged": charging_complete,
        "last_checkin": last_checkin
    }

    local jvars = http.jsonencode(weather);
    response.send(200,jvars);
}

// handle data from Imp
device.on("weatherImpData", function(data) {
    temp = format("%0.1f F", data.T);
    humidity = format("%0.0f %%", data.H);
    presssure = format("%0.0f Pa", data.P);
    battery = format("%0.2f V", data.V);
    charging = (data.C == 0) ? true: false;
    charging_complete = (data.D == 0) ? true: false;
    local current_date = date(time()+utc_offset);
    last_checkin = format("%4d-%02d-%-2d %02d:%02d:%02d", current_date.year,
                        current_date.month+1, current_date.day,
                        current_date.hour, current_date.min, current_date.sec);
    });

// Register callback
http.onrequest(respondImpData);
