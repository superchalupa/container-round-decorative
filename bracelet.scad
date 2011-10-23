use <container_module.scad>;

$fa=1;

bracelet_width=35;
radius=40;
wall_thick=3;
hole_len=6;
distance_between_holes=1;
hole_rotation_angle = 60;
num_divisions_around = 20;
edge_buffer=1; 

holy_squished_hollow_torus(bracelet_width, 
                           radius, 
                           wall_thick, 
                           edge_buffer, 
                           hole_len, 
                           distance_between_holes, 
                           hole_rotation_angle, 
                           num_divisions_around);
