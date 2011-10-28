layout="preview";
echo ("Running build for layout", layout);

use <container_module.scad>;

//$fs=1;    // minimum fragment size
//$fa=12;   // minimum fragment angle
//$fn=0;   // exact number of segments to use. '0' means use $fs and $fa

box_height=70;
radius=40;
wall_thick=3;
spiro_steps = 20;
bottom_thick=3;
spiro_line_width=1.5;
minor_radius=5;

hole_len=12;
distance_between_holes=4;
hole_rotation_angle = 60;
num_divisions_around = 12;

if (layout=="preview"){
    container_with_latches(box_height=box_height, 
              radius=radius,
              minor_radius=minor_radius,
              wall_thick=wall_thick,
              bottom_thick=bottom_thick,
              spiro_steps=spiro_steps,
              spiro_line_width=spiro_line_width,
              hole_len=hole_len,
              distance_between_holes=distance_between_holes,
              hole_rotation_angle=hole_rotation_angle,
              num_divisions_around=num_divisions_around);
    translate([0,0,box_height])
        rotate([180,0,0])
        spiro_container_lid_with_latches(box_height=box_height,
                      radius=radius,
                      minor_radius=minor_radius,
                      wall_thick=wall_thick,
                      bottom_thick=bottom_thick,
                      spiro_steps=spiro_steps,
                      spiro_line_width=spiro_line_width);
}

if (layout=="box"){
    container_with_latches(box_height=box_height,
              radius=radius,
              minor_radius=minor_radius,
              wall_thick=wall_thick,
              bottom_thick=bottom_thick,
              spiro_steps=spiro_steps,
              spiro_line_width=spiro_line_width,
              hole_len=hole_len,
              distance_between_holes=distance_between_holes,
              hole_rotation_angle=hole_rotation_angle,
              num_divisions_around=num_divisions_around);
}

if (layout=="lid"){
    spiro_container_lid_with_latches(box_height=box_height,
                  radius=radius,
                  minor_radius=minor_radius,
                  wall_thick=wall_thick,
                  bottom_thick=bottom_thick,
                  spiro_steps=spiro_steps,
                  spiro_line_width=spiro_line_width);
}

