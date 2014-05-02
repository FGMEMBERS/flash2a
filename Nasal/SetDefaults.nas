################################################################################################
#
# Set default values
#
################################################################################################

var set_defaults = func (device){

  if(device == "aerotow") {
    setprop("sim/hitches/aerotow/tow/brake-force", 1200.);
    setprop("sim/hitches/aerotow/rope/rope-diameter-mm", 8.);
  }
  
}





