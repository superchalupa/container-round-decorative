use <torus.scad>;
use <holes.scad>;

//$fs=1;    // minimum fragment size
//$fa=12;   // minimum fragment angle
//$fn=0;   // exact number of segments to use. '0' means use $fs and $fa

// for my 3 year old (small)
inside_radius=24;
minor_radius=8;

bracelet_width=35;
wall_thick=3;
hole_len=8;
distance_between_holes=2;
hole_rotation_angle = 70;
num_divisions_around = 12;
edge_buffer=3; 


translate([0,0,-1])
difference() {
    // A torus!
    squished_hollow_torus(inside_radius+minor_radius, minor_radius, bracelet_width, wall_thick);

    // punch those holes in it
    translate([0,0,3])
        holes(height=bracelet_width-6,
              radius=inside_radius+minor_radius,
              minor_radius=minor_radius,
              hole_len=hole_len,
              distance_between_holes=distance_between_holes,
              hole_rotation_angle=hole_rotation_angle,
              num_divisions_around=num_divisions_around);

// comment this out to make a 'tire'-looking bracelet
// slice it so it looks like MakeALot's bracelet:
//    translate([0,0,-1])
//        cylinder(h=bracelet_width+2,r=inside_radius+minor_radius+1, $fa=$fa/2, $fs=$fs/2);

    // make the ends flat to make it easier to print
    cylinder(h=1,r=inside_radius*2);
    translate([0,0,bracelet_width-1])
        cylinder(h=1,r=inside_radius*2);
}
