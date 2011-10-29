use <generic_container.scad>;
use <torus.scad>;
use <pins.scad>;
include <constants.scad>;
include <common_parameters.scad>;

layout="preview-pin";

pin_container_version = "1.1";
echo ("generic container version", generic_container_version);
echo ("pin container version", pin_container_version);

module container_with_pin(box_height, radius, minor_radius, wall_thick, bottom_thick, spiro_steps, spiro_line_width, hole_len, distance_between_holes, hole_rotation_angle, num_divisions_around) 
{
    pinhole_height = 10;
    pinhole_inside_radius = 4;
    pinhole_wall_thick=3;
    cube_s = 2*(pinhole_inside_radius+pinhole_wall_thick)*1.5; // approximate sqrt(2) = 1.5
    pin_attachment_h = pinhole_height+2*(pinhole_inside_radius+pinhole_wall_thick);

    union() {
        difference() {
            generic_container(box_height, radius, minor_radius, wall_thick, bottom_thick, spiro_steps, spiro_line_width, hole_len, distance_between_holes, hole_rotation_angle, num_divisions_around);

            translate([radius-2,0,box_height-bottom_thick-pin_attachment_h])
            translate([0,0,-0.5])
                cylinder(h=pin_attachment_h+1,r=pinhole_inside_radius);
            translate([radius-2,0,box_height-bottom_thick-pin_attachment_h])
            translate([0,0,pinhole_height+pin_attachment_h])
                rotate([180,0,0])
                pinhole(h=pinhole_height,r=pinhole_inside_radius,lh=3,lt=1, tight=true);

            translate([0,0,box_height])
                rotate([180,0,0])
                latch_detent(radius, minor_radius);

// undecided if these are useful or not yet
//            translate([0,0,box_height-bottom_thick])
//                rotate([0,180,180])
//                detents(radius, minor_radius, bottom_thick, wall_thick);
        }

        // The hole to hold the lid
        translate([radius-2,0,box_height-bottom_thick-pin_attachment_h])
        difference() {
            // it's a cylinder that merges into the side at 45 deg angle
            cylinder(h=pin_attachment_h,r=pinhole_inside_radius + pinhole_wall_thick);
            translate([0,0,-0.5])
                cylinder(h=pin_attachment_h+1,r=pinhole_inside_radius);
        
            // chop bottom off @ 45 deg
            translate([0,0,pinhole_inside_radius+pinhole_wall_thick])
                rotate([0,45,0])
                translate([0,0,-(sqrt(2)*(pinhole_inside_radius+pinhole_wall_thick)-smidgen)/2])
                cube([cube_s, cube_s,sqrt(2)*(pinhole_inside_radius+pinhole_wall_thick)+smidgen], center=true);
        
            // add full pinhole
            translate([0,0,pinhole_height+pin_attachment_h])
                rotate([180,0,0])
                pinhole(h=pinhole_height,r=pinhole_inside_radius,lh=3,lt=1, tight=true);
        
        }
    }
}


module generic_container_lid_with_pin(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width) {
    union() {
        generic_lid(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);

        latch(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);
        
        // pin w/ extra cyl so we dont have coincident faces
        translate([radius-2,0,0])
            cylinder(h=bottom_thick+1,r=4);
        translate([radius-2,0,bottom_thick])
            pin(h=10,r=4,lh=3,lt=1);
    }
}


module spiro_container_lid_with_pin(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width)
{
    union() {
        generic_container_lid_with_pin(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);
        spiro(radius/2, spiro_line_width, bottom_thick, spiro_steps);
    }
}


if (layout=="preview-pin"){
    container_with_pin(box_height=box_height, 
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
        spiro_container_lid_with_pin(box_height=box_height,
                      radius=radius,
                      minor_radius=minor_radius,
                      wall_thick=wall_thick,
                      bottom_thick=bottom_thick,
                      spiro_steps=spiro_steps,
                      spiro_line_width=spiro_line_width);
}

if (layout=="box-pin"){
    container_with_pin(box_height=box_height,
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

if (layout=="lid-pin"){
    spiro_container_lid_with_pin(box_height=box_height,
                  radius=radius,
                  minor_radius=minor_radius,
                  wall_thick=wall_thick,
                  bottom_thick=bottom_thick,
                  spiro_steps=spiro_steps,
                  spiro_line_width=spiro_line_width);
}

