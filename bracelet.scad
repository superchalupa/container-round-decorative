use <container_module.scad>;

//$fs=1;    // minimum fragment size
//$fa=12;   // minimum fragment angle
//$fn=0;   // exact number of segments to use. '0' means use $fs and $fa


// for my 3 year old (small)
radius=23;

bracelet_width=35;
wall_thick=3;
hole_len=8;
distance_between_holes=1;
hole_rotation_angle = 80;
num_divisions_around = 16;
edge_buffer=2; 

holy_squished_hollow_torus(bracelet_width, 
                           radius, 
                           wall_thick, 
                           edge_buffer, 
                           hole_len, 
                           distance_between_holes, 
                           hole_rotation_angle, 
                           num_divisions_around);
