################################################################################################
#
# Set default aerotow values
#
################################################################################################

var set_defaults = func (device){

  if(device == "aerotow") {
    #setprop("sim/hitches/aerotow/tow/brake-force", 1200.);  
    # should be 1200N in real life due to safety reasons. Here set to a high value to avoid frustrations
    # (timelag in multiplayer could lead to higher forces).
    setprop("sim/hitches/aerotow/tow/brake-force", 10000.);  
    
    setprop("sim/hitches/aerotow/rope/rope-diameter-mm", 8.);
  }  
}


################################################################################################
#
# Set default weight values
#
################################################################################################

var weight_and_balance_defaults = func {

  setprop("/fdm/jsbsim/inertia/pointmass-weight-kg[0]", 100.);    # trike + engine
  setprop("/fdm/jsbsim/inertia/pointmass-weight-kg[1]", 75.);	  # pilot
  setprop("/fdm/jsbsim/inertia/pointmass-weight-kg[2]", 15.);	  # passenger or ballast
  
  weight_and_balance()
}





