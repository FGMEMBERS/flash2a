var ViewAndHitchAnimation = func {
#
# ---------------------------------------------------------------------------------
#                        View and Hitch Animation               Status: 11.01.2015
# ---------------------------------------------------------------------------------
#
#
# Definitions:
# ----------------
#
# roll     pitch     
# alpha    beta      
# aileron  elevator  
# +-15deg  -9/+9deg 
#                       
#                              
#       z                  y       
#       |  y               |  x       
#       | / 	           | / 
#       |/ 	           |/ 
#       ----->x	           ----->z
#		          
#		        
#     FDM-System          View-System
# (Structural Frame)
#
#
# view-no |         name       | animation on ground |  animation in air    |
#---------|--------------------|---------------------|----------------------|
#     0   | Cockpit View       |          -          |           -          |   
#     8   | Keel View          |          -          |           -          |
#     9   | Right Wing View    |          -          |           -          | 
#    10   | Left Wing View     | deflection + angle  |                      |
#    11   | Pilot View Animated|          -          | deflection w/o angle |
#         | Hitch              |          -          | deflection w/o angle |
#         | Wheels             |          -          |         not yet      |
#        
#--------------------------------------------------------------------------

var m2in = 39.3700787;

var view_number = getprop("sim/current-view/view-number");

var on_ground   = 0;
if ( view_number == 0 ) on_ground = 1;
if ( getprop("gear/gear[2]/wow")  == 1 and getprop("gear/gear[2]/wow") == 1 ) on_ground = 1;

setprop("sim/model/flash2a/on_ground",on_ground);

var mode = ["dummy","dummy","dummy"];
var device=["dummy","dummy","dummy"];
var hitch= ["dummy","dummy","dummy"];

var n_loop = 0;

if ( view_number == 10 or view_number == 11 ) {
  n_loop = n_loop + 1;
  mode[n_loop-1] = "view_animation";
  }
if ( getprop("sim/hitches/aerotow/open") == 0 ) {
  n_loop = n_loop + 1;
  mode[n_loop-1] = "hitch_animation";
  device[n_loop-1] = "aerotow";
  hitch[n_loop-1] = getprop("sim/hitches/aerotow/force_name_jsbsim");
  }
  
for (var n=0; n < n_loop; n = n+1) {   

  var rotation = 0;     # help variable (0:= do not run rotation routine / 1:= run rotation routine

  if( mode[n] == "view_animation") {  
    if ( view_number == 0 ) {
      # Point to rotate = X = (x,y,z) (Eyes; FDM-system)
      #var x = 1.3;
      #var y = 0;
      #var z = 0.65;
      var x = 1.188;
      var y = 0;
      var z = 0.8526;
      if ( on_ground == 0 ) { var rotation = 1; };
    }
    else if ( view_number == 11 ) {
      # Point to rotate = X = (x,y,z) (Cockpit View Animated; FDM-system)
      #var x = 1.3;
      #var y = 0.;
      #var z = 0.65;
      var x = 1.188;
      var y = 0;
      var z = 0.8526;      
      if ( on_ground == 0 ) { var rotation = 1; };
    }
    else if ( view_number == 10 ) {
      # Point to rotate = X = (x,y,z) (Left Wing View; FDM-system)
      var x =  1.4;
      var y = -5.5;
      var z =  2.0;
      if ( on_ground == 1 ) { var rotation = 1; };
      var rotation_harness = 1;
    }
  } # end mode view_animation
  else if ( mode[n] == "hitch_animation") {
    # Point to rotate = X = (x,y,z) (hitch; FDM-system)
    if ( hitch[n] == "hitch" ) {
      var x = 2.3;
      var y = 0.;
      var z = 0.5523;
      if ( on_ground == 0 ) rotation = 1;
    } 
    else {
      var x = 0.;
      var y = 0.;
      var z = 0.;
    }
  } # end mode hitch_animation

  if (n == 0 ) {
  
    # Center of rotation = Xr = (xr,yr,zr) (FDM-system)
    var xr = 1.55;
    var yr = 0.;
    #	var zr = 1.96;  # center for elevator
    var zr = 2.04;      # center for aileron
    
    # defaults are necessary to avoid nasal runtime errors
    var x_new = x;   
    var y_new = y;
    var z_new = z;
    var roll_zyx    = 0.;    
    var pitch_zyx   = 0.; 
    var heading_zyx = 0.;
    #----------------------------------------------------------------------------------
   
    # get variables
    var aileron       = getprop("surface-positions/left-aileron-pos-norm");
    var elevator      = - getprop("surface-positions/elevator-pos-norm");
    var rudder        = 0.;
    #var elevator_trim = getprop("controls/flight/elevator-trim");


    # Deflections
    var fak = math.pi / 180.;
    var fakh = fak;
    if ( on_ground == 1 ) { var fak = -1 * fak};  # switch reference system

    var roll_offset_deg = aileron * 15.;
    var sin_alpha = math.sin(aileron * 15. * fak);
    var cos_alpha = math.cos(aileron * 15. * fak);

    var pitch_offset_deg = elevator * 9.;				 
    var sin_beta  = math.sin(elevator * 9. * fak);
    var cos_beta  = math.cos(elevator * 9. * fak);

    var heading_offset_deg = rudder * 40.;
    var sin_gamma = math.sin(rudder * 40.* fak);
    var cos_gamma = math.cos(rudder * 40.* fak);
  
  }  # end n=0
  
   
  if ( rotation == 1 ) {
  
    # Transformation in glider rotation-system X_rel = X-Xr = (x-xr, y-yr, z-zr)
    var x_rel = x-xr;
    var y_rel = y-yr;  
    var z_rel = z-zr;  
    #
    # Rotate about x-axis Rx(alpha) 
    #
    #		  Rx11 Rx12 Rx13      1     0		 0
    # Rx(alpha)=  Rx21 Rx22 Rx23   =  0  cos(alpha)  -sin(alpha)
    #		  Rx31 Rx32 Rx33      0  sin(alpha)   cos(alpha)
    #
    var Rx11 = 1.;
    var Rx12 = 0.;
    var Rx13 = 0.;
    var Rx21 = 0.;
    var Rx22 = cos_alpha;
    var Rx23 = - sin_alpha;
    var Rx31 = 0.;
    var Rx32 = sin_alpha;
    var Rx33 = cos_alpha;
    #
    # Rotate about y-axis Ry(beta) 
    #
    #		 Ry11 Ry12 Ry13      cos(beta)  0   sin(beta)	
    # Ry(beta)=  Ry21 Ry22 Ry23   =	 0	1      0 
    #		 Ry31 Ry32 Ry33     -sin(beta)  0   cos(beta)
    #
    var Ry11 = cos_beta;
    var Ry12 = 0.;
    var Ry13 = sin_beta;
    var Ry21 = 0.;
    var Ry22 = 1.;
    var Ry23 = 0.;
    var Ry31 = - sin_beta;
    var Ry32 = 0.;
    var Ry33 = cos_beta;
    #
    # Rotate about z-axis Rz(gamma) 
    #
    #		 Rz11 Rz12 Rz13      cos(gamma)  -sin(gamma)  0  
    # Rz(gamma)= Rz21 Rz22 Rz23   =  sin(gamma)   cos(gamma)  0   
    #		 Rz31 Rz32 Rz33 	 0	      0       1
    #
    var Rz11 = cos_gamma;
    var Rz12 = - sin_gamma;
    var Rz13 = 0.;
    var Rz21 = sin_gamma;
    var Rz22 = cos_gamma;
    var Rz23 = 0.;
    var Rz31 = 0.;
    var Rz32 = 0.;
    var Rz33 = 1.; 
    #
    # First rotation about z-axis
    # X_z = Rz*X_rel
    var x_z = Rz11 * x_rel + Rz12 * y_rel + Rz13 * z_rel;
    var y_z = Rz21 * x_rel + Rz22 * y_rel + Rz23 * z_rel;
    var z_z = Rz31 * x_rel + Rz32 * y_rel + Rz33 * z_rel; 

    var roll_z    = Rz11 * roll_offset_deg + Rz12 *  pitch_offset_deg + Rz13 * heading_offset_deg;
    var pitch_z   = Rz21 * roll_offset_deg + Rz22 *  pitch_offset_deg + Rz23 * heading_offset_deg;
    var heading_z = Rz31 * roll_offset_deg + Rz32 *  pitch_offset_deg + Rz33 * heading_offset_deg;      
    #
    # subsequent rotation about y-axis
    # X_zy = Ry*X_z
    var x_zy = Ry11 * x_z + Ry12 * y_z + Ry13 * z_z;
    var y_zy = Ry21 * x_z + Ry22 * y_z + Ry23 * z_z;
    var z_zy = Ry31 * x_z + Ry32 * y_z + Ry33 * z_z;  
    
    var roll_zy    = Ry11 * roll_z + Ry12 * pitch_z + Ry13 * heading_z;
    var pitch_zy   = Ry21 * roll_z + Ry22 * pitch_z + Ry23 * heading_z;
    var heading_zy = Ry31 * roll_z + Ry32 * pitch_z + Ry33 * heading_z;  
    #
    # subsequent rotation about x-axis:
    # X_zyx = Rx*X_zy
    var x_zyx = Rx11 * x_zy + Rx12 * y_zy + Rx13 * z_zy;
    var y_zyx = Rx21 * x_zy + Rx22 * y_zy + Rx23 * z_zy;
    var z_zyx = Rx31 * x_zy + Rx32 * y_zy + Rx33 * z_zy; 
    
    var roll_zyx    = Rx11 * roll_zy + Rx12 * pitch_zy + Rx13 * heading_zy;
    var pitch_zyx   = Rx21 * roll_zy + Rx22 * pitch_zy + Rx23 * heading_zy;
    var heading_zyx = Rx31 * roll_zy + Rx32 * pitch_zy + Rx33 * heading_zy; 

    #----------------------------------------------------------------------
    #
    #				   
    #	    z		       y       
    #	    |  y	       |  x	  
    #	    | / 	       | / 
    #	    |/  	       |/ 
    #	    ----->x	       ----->z
    #			      
    #			    
    #	  FDM-System	      View-System
    # (Structural Frame)
    #
    #
    #
    # FDM-System
    var x_new = xr + x_zyx;
    var y_new = yr + y_zyx;
    var z_new = zr + z_zyx;
  }
  
  if( mode[n] == "view_animation") {
    
    # View-System  
    setprop("sim/current-view/x-offset-m",y_new);      
    setprop("sim/current-view/y-offset-m",z_new);
    setprop("sim/current-view/z-offset-m",x_new);
  
   # if ( view_number == 0 ) {
   #   # Pilot View
   #   setprop("sim/current-view/pitch-offset-deg",pitch_zyx -10.);      
   #   setprop("sim/current-view/roll-offset-deg",-roll_zyx);
   #   setprop("sim/current-view/heading-offset-deg",heading_zyx); 
   # }

    if ( view_number == 10 ) {
      # Left Wing View
      var pitch_xyzq = -pitch_zyx - 0. ;
      var heading_xyzq = -heading_zyx - 85. ;
      setprop("sim/current-view/pitch-offset-deg",-roll_zyx - 8.);      
      setprop("sim/current-view/roll-offset-deg",pitch_xyzq);
      setprop("sim/current-view/heading-offset-deg",heading_xyzq); 
    }
  }
  if ( mode[n] == "hitch_animation") {
    # force location
    setprop("fdm/jsbsim/external_reactions/" ~ hitch[n]~ "/location-x-in",x_new * m2in);
    setprop("fdm/jsbsim/external_reactions/" ~ hitch[n]~ "/location-y-in",y_new * m2in);
    setprop("fdm/jsbsim/external_reactions/" ~ hitch[n]~ "/location-z-in",z_new * m2in);
  } # end mode hitch_animation
  
}  # end loop
		  
  	settimer(ViewAndHitchAnimation,0);
}  
# Start ViewAndHitchAnimation ASAP
ViewAndHitchAnimation();
