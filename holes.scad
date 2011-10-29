
module holes(height=35, radius=35, minor_radius=5, hole_len=12, distance_between_holes=1, hole_rotation_angle=60, num_divisions_around=20) {
    oval_maj_rad=hole_len/2;
    y_step = sin(hole_rotation_angle) * (oval_maj_rad*2+distance_between_holes);
    num_big_ovals = floor(height/y_step);
    degrees_per_y =  360 * tan(90-hole_rotation_angle) / (2 * 3.141592 * radius);
    echo ("height: ", height);
    echo ("y_step: ", y_step);
    echo ("num big ovals: ", num_big_ovals);
    echo ("degrees_per_y_unit", degrees_per_y);

    // Ok, this was a pain to come up with, but basically here we chop holes in the sides
    // outer loop copies each individual vertical 'line' around the circumference
    // inner loop does one individual 'line' of holes going up
    for (i=[0:num_divisions_around-1]) {
        // first row
        for (j=[0:num_big_ovals-1]) {
            rotate([0,0,i*(360/num_divisions_around)+j*(degrees_per_y*y_step)])
                translate([radius-minor_radius-smidgen,0,y_step/2 + j*y_step])
                rotate([hole_rotation_angle,0,0])
                rotate([0,90,0])
                scale([1.5/oval_maj_rad,1,1])
                cylinder(h=minor_radius*2+smidgen*2,r1=oval_maj_rad, r2=oval_maj_rad);
        }

        // The 'odd' row (starts with half oval, but we skip that in this loop)
        for (j=[0:num_big_ovals-2]) {
            rotate([0,0,(i+0.5)*(360/num_divisions_around)+j*(degrees_per_y*y_step)+degrees_per_y*y_step/2])
                translate([radius-minor_radius-smidgen,0,y_step + j*y_step])
                rotate([hole_rotation_angle,0,0])
                rotate([0,90,0])
                scale([1.5/oval_maj_rad,1,1])
                cylinder(h=minor_radius*2+smidgen*2,r1=oval_maj_rad, r2=oval_maj_rad);
        }

        // here we get the odd half-sized ones on the bottom
        // uses same formula as above, but I simplified couple terms manually
        rotate([0,0,(i+0.5)*(360/num_divisions_around)-degrees_per_y*y_step/4])
            translate([radius-minor_radius-smidgen,0,y_step/4])
            rotate([hole_rotation_angle,0,0])
            rotate([0,90,0])
            scale([1.5/oval_maj_rad,1/2,1])
            cylinder(h=minor_radius*2+smidgen*2,r1=oval_maj_rad, r2=oval_maj_rad);

        // here we get the odd half-sized ones on the top
        // uses same formula as above, but I simplified couple terms manually
        rotate([0,0,(i+0.5)*(360/num_divisions_around)+(num_big_ovals-1)*(degrees_per_y*y_step)+degrees_per_y*y_step/4])
            translate([radius-minor_radius-smidgen,0,y_step + (num_big_ovals-1)*y_step - y_step/4])
            rotate([hole_rotation_angle,0,0])
            rotate([0,90,0])
            scale([1.5/oval_maj_rad,1/2,1])
            cylinder(h=minor_radius*2+smidgen*2,r1=oval_maj_rad, r2=oval_maj_rad);
    }
}

include <constants.scad>;
include <common_parameters.scad>;
layout="holes";
if (layout=="holes"){
    holes(height=box_height-(bottom_thick+3)*2,
          radius=radius,
          minor_radius=minor_radius,
          hole_len=hole_len,
          distance_between_holes=distance_between_holes,
          hole_rotation_angle=hole_rotation_angle,
          num_divisions_around=num_divisions_around);
}
