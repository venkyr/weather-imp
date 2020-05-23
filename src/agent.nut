//////////////////////
// Global Variables //
//////////////////////
temp <- 0;
rh <- 0;
last_checkin <- "Never";

//////////////////////////
// Function Definitions //
//////////////////////////

// respondImpValues is called whenever an http request is received.
// This function will construct a JSON table containing our most recently
// received imp pin values, then send that out to the requester.
function respondImpValues(request,response){

    // First, construct a JSON table with our received pin values.
    local weather = {
        "temp": temp+"F",
        "humidity": rh+"%",
        "last_checkin": last_checkin+""
    }

    // the http.jsonencode(object) function takes a squirrel variable and returns a
    // standardized JSON string. - https://electricimp.com/docs/api/http/jsonencode/
    local jvars = http.jsonencode(weather);

    // Attach a header to our response.
    // "Access-Control-Allow-Origin: *" allows cross-origin resource sharing
    // https://electricimp.com/docs/api/httpresponse/header/
    response.header("Access-Control-Allow-Origin", "*");

    // Send out our response. 
    // 200 is the "OK" http status code
    // jvars is our response string. The JSON table we constructed earlier.
    // https://electricimp.com/docs/api/httpresponse/send/
    response.send(200,jvars);
}

// device.on("impValues") will be called whenever an "impValues" request is sent
// from the device side. This simple function simply fills up our global variables
// with the equivalent vars received from the imp.
device.on("impValues", function(iv) {
    temp = iv.temp;
    rh = iv.rh;
    local current_date = date(time());
    last_checkin = format("%4d-%02d-%-2d %02d:%02d:%02d", current_date.year,
                        current_date.month+1, current_date.day,
                        current_date.hour, current_date.min, current_date.sec);
    });

///////////
// Setup //
///////////

// http.onrequest(function) sets up a function handler to call when an http
// request is received. Whenever we receive an http request call respondImpValues
// https://electricimp.com/docs/api/http/onrequest/
http.onrequest(respondImpValues);
