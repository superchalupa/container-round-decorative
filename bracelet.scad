use <container_module.scad>;

//$fs=1;    // minimum fragment size
//$fa=12;   // minimum fragment angle
//$fn=0;   // exact number of segments to use. '0' means use $fs and $fa
$fn=10;   // exact number of segments to use. '0' means use $fs and $fa


// for my 3 year old (small)
inside_radius=24;
minor_radius=4;

bracelet_width=35;
wall_thick=3;
hole_len=8;
distance_between_holes=1;
hole_rotation_angle = 70;
num_divisions_around = 12;
edge_buffer=3; 


translate([0,0,-1])
difference() {
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
//    translate([0,0,-1])
//        cylinder(h=bracelet_width+2,r=inside_radius+minor_radius+1, $fa=$fa/2, $fs=$fs/2);

    cylinder(h=1,r=inside_radius*2);
    translate([0,0,bracelet_width-1])
        cylinder(h=1,r=inside_radius*2);
}
