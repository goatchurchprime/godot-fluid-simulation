# godot-fluid-simulation

After seeing a lovely fluid simulation in the VRChat world [Camera Test](https://vrchat.com/home/launch?worldId=wrld_91805f98-fd56-497a-bf7e-772e434efb84)
(among 6 other amazing effects that we should try to implement in GodotVR), the closest code I found to it was
[paveldogreat.github.io/WebGL-Fluid-Simulation](https://paveldogreat.github.io/WebGL-Fluid-Simulation/).

I have ported some of it from WebGL to Godot shaders based on a series of Viewports each linking the output to the next.

Implementing Bloom is left to another day as it is very complex involving a series of 
decreasing viewport frame sizes.  The code is here:  
https://github.com/PavelDoGreat/WebGL-Fluid-Simulation/blob/master/script.js

![image](https://github.com/user-attachments/assets/698a1a6c-1570-4af3-bce0-5b25e21fb3a6)
