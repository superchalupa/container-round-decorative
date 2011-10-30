use <generic_container.scad>;
use <torus.scad>

include <constants.scad>;
include <common_parameters.scad>;
 
layout="preview-latches";

latch_container_version = "1.1";
echo ("generic container version", generic_container_version);
echo ("latch container version", latch_container_version);

module container_with_latches(box_height, radius, minor_radius, wall_thick, bottom_thick, spiro_steps, spiro_line_width, hole_len, distance_between_holes, hole_rotation_angle, num_divisions_around)
{
    difference() {
        generic_container(box_height, radius, minor_radius, wall_thick, bottom_thick, spiro_steps, spiro_line_width, hole_len, distance_between_holes, hole_rotation_angle, num_divisions_around);

        translate([0,0,box_height])
            rotate([180,0,0])
            latch_detent(radius, minor_radius, bottom_thick);

        translate([0,0,box_height])
            rotate([180,0,180])
            latch_detent(radius, minor_radius, bottom_thick);
    }
}


module generic_container_lid_with_latches(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width)
{
    union() {
        generic_lid(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);
        latch(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);
        rotate([0,0,180])
            latch(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);
    }
}



module spiro_container_lid_with_latches(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width)
{
    union() {
        generic_container_lid_with_latches(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);

        // make a ring detent to positively engage top of box
        tube(radius-fitting_windage_snug, spiro_line_width-fitting_windage_snug, bottom_thick+2);

        spiro(radius/2, spiro_line_width, bottom_thick, spiro_steps);
    }
}

if (layout=="preview-latches"){
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

if (layout=="box-latches"){
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

if (layout=="lid-latches"){
    spiro_container_lid_with_latches(box_height=box_height,
                  radius=radius,
                  minor_radius=minor_radius,
                  wall_thick=wall_thick,
                  bottom_thick=bottom_thick,
                  spiro_steps=spiro_steps,
                  spiro_line_width=spiro_line_width);
}


