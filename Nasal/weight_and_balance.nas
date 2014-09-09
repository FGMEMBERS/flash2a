################################################################################################
#
# calculate CG positions and convert units
#
################################################################################################

var weight_and_balance = func {

  # ------------------------  convert units  ------------------------
  
  var weight_empty_lbs = getprop("/fdm/jsbsim/inertia/empty-weight-lbs");
  var weight_empty_kg = weight_empty_lbs * 0.453592;
  setprop("/fdm/jsbsim/inertia/empty-weight-kg",weight_empty_kg);
 
  var weight_trike_kg = getprop("/fdm/jsbsim/inertia/pointmass-weight-kg[0]");
  var weight_trike_lbs = weight_trike_kg * 2.204623;
  setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]",weight_trike_lbs) ;

  var weight_pilot_kg = getprop("/fdm/jsbsim/inertia/pointmass-weight-kg[1]");
  var weight_pilot_lbs = weight_pilot_kg * 2.204623;
  setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]",weight_pilot_lbs) ;

  var weight_passenger_kg = getprop("/fdm/jsbsim/inertia/pointmass-weight-kg[2]");
  var weight_passenger_lbs = weight_passenger_kg * 2.204623;
  setprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[2]",weight_passenger_lbs) ;

  var weight_fuel_lbs = getprop("/consumables/fuel/total-fuel-lbs");

  var weight_lbs = getprop("/fdm/jsbsim/inertia/weight-lbs");
  var weight_kg = weight_lbs * 0.453592;
  setprop("/fdm/jsbsim/inertia/weight-kg",weight_kg);

  # ------  calculate weight of loaded trike  -----------
  #
  var weight_non_lift_lbs =    weight_trike_lbs
  			     + weight_pilot_lbs
     			     + weight_passenger_lbs
     			     + weight_fuel_lbs
     			     ;
  setprop("/fdm/jsbsim/inertia/weight_non_lift-lbs",weight_non_lift_lbs);		     
  var weight_non_lift_kg = weight_non_lift_lbs * 0.453592;
  setprop("/fdm/jsbsim/inertia/weight_non_lift-kg",weight_non_lift_kg);


  var area_sqft = getprop("/fdm/jsbsim/metrics/Sw-sqft");
  var area_sqm = area_sqft * 0.09290;
  setprop("/fdm/jsbsim/metrics/Sw-sqm",area_sqm);


  # ------------------------  calculate CG position of loaded trike ------------------------
  #
  #  Important: Datum is the trike nose!
  #
  #  the first part of this routine is not really necessary! 
  #  /fdm/jsbsim/systems/weightshift/cg-x-in has done the job already!
  #  1mm = 0.0393701inch
  #  1m  = 39.3701inch
  var x_trike     = getprop("/fdm/jsbsim/systems/weightshift/pointmass-location-X-inches[0]");
  var x_pilot     = getprop("/fdm/jsbsim/systems/weightshift/pointmass-location-X-inches[1]");
  var x_passenger = getprop("/fdm/jsbsim/systems/weightshift/pointmass-location-X-inches[2]");
  var x_fuel_t0   = 87.;
  var x_fuel_t1   = 70.;

  var z_trike     = getprop("/fdm/jsbsim/systems/weightshift/pointmass-location-Z-inches[0]");
  var z_pilot     = getprop("/fdm/jsbsim/systems/weightshift/pointmass-location-Z-inches[1]");
  var z_passenger = getprop("/fdm/jsbsim/systems/weightshift/pointmass-location-Z-inches[2]");
  var z_fuel_t0   = 9.6;
  var z_fuel_t1   = 4.0;

  var m_trike     = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[0]");
  var m_pilot     = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[1]");
  var m_passenger = getprop("/fdm/jsbsim/inertia/pointmass-weight-lbs[2]");
  var m_fuel_t0   = getprop("/consumables/fuel/tank[0]/level-lbs");
  var m_fuel_t1   = getprop("/consumables/fuel/tank[1]/level-lbs");

  
  var x_cg_trike_inch = ( m_trike * x_trike + m_pilot * x_pilot + m_passenger * x_passenger + 
                          m_fuel_t0 * x_fuel_t0 + m_fuel_t1 * x_fuel_t1 ) / 
                        ( m_trike + m_pilot + m_passenger + m_fuel_t0 + m_fuel_t1 ) ;
  var x_cg_trike_mm = x_cg_trike_inch / 0.0393701 ; 

  setprop("/fdm/jsbsim/systems/weightshift/cg_trike-x-inch",x_cg_trike_inch) ;	     
  setprop("/fdm/jsbsim/systems/weightshift/cg_trike-x-mm",x_cg_trike_mm) ;

  var z_cg_trike_inch = ( m_trike * z_trike + m_pilot * z_pilot + m_passenger * z_passenger + 
                          m_fuel_t0 * z_fuel_t0 + m_fuel_t1 * z_fuel_t1 ) / 
                        ( m_trike + m_pilot + m_passenger + m_fuel_t0 + m_fuel_t1 ) ;
  var z_cg_trike_mm = z_cg_trike_inch / 0.0393701 ; 

  setprop("/fdm/jsbsim/systems/weightshift/cg_trike-z-inch",z_cg_trike_inch) ;	     
  setprop("/fdm/jsbsim/systems/weightshift/cg_trike-z-mm",z_cg_trike_mm) ;


  # --- distance cg_trike hangpoint ---
  var hp_x_inch = 61.  ;
  var hp_y_inch =  0.  ;
  var hp_z_inch = 77.17;

  var hp_x_inch = getprop("/fdm/jsbsim/systems/weightshift/hangpoint-x-inch");
  #var hp_y_inch = getprop("/fdm/jsbsim/systems/weightshift/hangpoint-y-inch");
  var hp_z_inch = getprop("/fdm/jsbsim/systems/weightshift/hangpoint-z-inch");  

  var dx = x_cg_trike_inch - hp_x_inch ;
  var dz = z_cg_trike_inch - hp_z_inch ;
  var dist = math.sqrt ( dx*dx+dz*dz );
  setprop("/fdm/jsbsim/systems/weightshift/distance_cg_trike2hp-in",dist) ;
  setprop("/fdm/jsbsim/systems/weightshift/distance_cg_trike2hp-m",dist/39.37) ;
  setprop("/fdm/jsbsim/systems/weightshift/distance_x_cg_trike2hp-in",dx) ;
  setprop("/fdm/jsbsim/systems/weightshift/distance_x_cg_trike2hp-m",dx/39.37) ;
  setprop("/fdm/jsbsim/systems/weightshift/distance_z_cg_trike2hp-in",dz) ;
  setprop("/fdm/jsbsim/systems/weightshift/distance_z_cg_trike2hp-m",dz/39.37) ;   

  # --- wing loading ---
  var wing_loading_lbft2 = weight_lbs / area_sqft ;
  var wing_loading_kgm2  = weight_kg  / area_sqm ;
  setprop("/fdm/jsbsim/inertia/wing_loading_lbsqft",wing_loading_lbft2) ;
  setprop("/fdm/jsbsim/inertia/wing_loading_kgsqm",wing_loading_kgm2) ;  
#print(" Weight and Balance ");
}

# Initialize at startup (Important for JSBSim) 
weight_and_balance();


