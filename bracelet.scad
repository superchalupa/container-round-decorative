use <container_module.scad>;

//$fs=1;    // minimum fragment size
//$fa=12;   // minimum fragment angle
//$fn=0;   // exact number of segments to use. '0' means use $fs and $fa


// for my 3 year old (small)
inside_radius=20;

bracelet_width=35;
wall_thick=3;
hole_len=8;
distance_between_holes=1;
hole_rotation_angle = 70;
num_divisions_around = 12;
edge_buffer=3; 
minor_radius=8;


translate([0,0,-1])
difference() {
    union() {
        holy_squished_hollow_torus(bracelet_width, 
                           inside_radius+minor_radius, 
                           wall_thick, 
                           edge_buffer, 
                           hole_len, 
                           distance_between_holes, 
                           hole_rotation_angle, 
                           num_divisions_around,
                           minor_radius
                           );
    }
    cylinder(h=1,r=inside_radius*2);
    translate([0,0,bracelet_width-1])
        cylinder(h=1,r=inside_radius*2);
}
