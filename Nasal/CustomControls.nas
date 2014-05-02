var custom_control = func {
  if ( getprop("sim/model/flash2a/custom-control") == "normal" ) {
    setprop("controls/flight/elevator_custom", getprop("controls/flight/elevator") * (-1) );
    setprop("controls/flight/aileron_custom", getprop("controls/flight/aileron") );
  }
  else if ( getprop("sim/model/flash2a/custom-control") == "inverted" ) {
    setprop("controls/flight/elevator_custom", getprop("controls/flight/elevator") );
    setprop("controls/flight/aileron_custom", getprop("controls/flight/aileron") * (-1) );
  }
  else {
    setprop("controls/flight/elevator_custom", getprop("controls/flight/elevator") );
    setprop("controls/flight/aileron_custom", getprop("controls/flight/aileron") );
  } 
	  
  settimer(custom_control,0);
}

# Start the custom_control ASAP
custom_control();
