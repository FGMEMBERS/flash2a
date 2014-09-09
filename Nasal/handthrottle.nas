checkHandThrottle = func {
  var lhandpos = getprop("/controls/engines/engine[0]/handthrottle");
  var lfootpos = getprop("/controls/engines/engine[0]/footthrottle");

  if ((lhandpos != nil) and (lfootpos != nil))
  {
    # If the hand position and the foot position are defined, use the maximum of them
    if (lhandpos > lfootpos)
    {
      setprop("/controls/engines/engine[0]/throttle", lhandpos);  
    }
    else
    {
      setprop("/controls/engines/engine[0]/throttle", lfootpos);  
    }
  }  
  else
  {
    # If we don't have both, then use the hand position only if it is greater than 0.1
    # as the user is not using the modified pedal controls
    if ((lhandpos != nil) and (lhandpos > 0.1))
    {
      setprop("/controls/engines/engine[0]/throttle", lhandpos);  
    }
  }
  
  # Rather than use a listener, we'll use a timer. This simulates the fact that
  # the throttle response on the 503 rotax leaves a lot to be desired
  settimer(checkHandThrottle, 0.25);
}

setlistener("/sim/signals/fdm-initialized", checkHandThrottle);

