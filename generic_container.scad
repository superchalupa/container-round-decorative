layout="preview";
echo ("Running build for", layout);

use <holes.scad>;
use <torus.scad>;
use <pins.scad>;

// use this when subtracting surfaces and we want to make sure they dont coincide
smidgen = 0.5;
tiniest_smidgen = 0.05;

// use this when parts have to fit together 
fitting_windage_loose=0.350;
fitting_windage_snug=0.250;

module generic_container(box_height, radius, minor_radius, wall_thick, bottom_thick, spiro_steps, spiro_line_width, hole_len, distance_between_holes, hole_rotation_angle, num_divisions_around) 
{
    union() {
        // the bottom spiro graph
        tube(radius+1, spiro_line_width, bottom_thick);
        spiro(radius/2, spiro_line_width, bottom_thick, spiro_steps);
        cylinder(h=1,r=radius+1);

        difference() {
            squished_hollow_torus(radius, minor_radius, box_height, wall_thick);
            translate([0,0,-smidgen])
                cylinder(h=box_height+2*smidgen,r=radius);
            translate([0,0,box_height-bottom_thick])
                cylinder(h=bottom_thick+10,r=radius+minor_radius+smidgen);
            translate([0,0,bottom_thick+3])
                holes(
                      height=box_height-(bottom_thick+3)*2,
                      radius=radius,
                      minor_radius=minor_radius,
                      hole_len=hole_len,
                      distance_between_holes=distance_between_holes,
                      hole_rotation_angle=hole_rotation_angle,
                      num_divisions_around=num_divisions_around);
        }
    }
}


module detents(radius, minor_radius, wall_thick, bottom_thick)
{
        // detents
        translate([0, (radius+smidgen), 0.4])
            cube( [ wall_thick,  wall_thick, 1.1], center=true);
        translate([0,-(radius+smidgen), 0.4])
            cube( [ wall_thick,  wall_thick, 1.1], center=true);
}

module latch_detent(radius, minor_radius, bottom_thick)
{
    clip_r = 7*minor_radius/12;
    clip_midpoint_h = 5;
    clip_w = 10;

    union() {
        translate([-radius-minor_radius,0,bottom_thick+clip_midpoint_h])
            difference() {
                rotate([90,0,0])
                    cylinder(h=10,r=clip_r,center=true);
    
                translate([ -2*clip_r,  -clip_w,  -clip_r  -smidgen])
                    cube([2*clip_r, 2*clip_w, 2*clip_r+2*smidgen]);
            }
    }
}

module latch(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width)
{
    clip_r = 7*minor_radius/12;
    clip_midpoint_h = 5;
    clip_w = 10;

    union() {
        difference() {
            translate([-radius-minor_radius,-(clip_w/2),0])
                cube([minor_radius,clip_w,bottom_thick+clip_midpoint_h]);

            translate([0,0,-smidgen])
                cylinder(r=radius, h=box_height);
            translate([0,0,-tiniest_smidgen])
                squished_solid_torus(radius, minor_radius, box_height);
        }

        latch_detent(radius, minor_radius, bottom_thick);
    }
}

module generic_lid(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width)
{
    union() {
        // matching curve of box
        difference() {
            squished_solid_torus(radius, minor_radius, box_height);
            translate([0,0,-smidgen])cylinder(h=box_height+2*smidgen,r=radius);
            translate([0,0,bottom_thick]) cylinder(h=box_height,r=radius+minor_radius+smidgen);
        }

        // outside tube and spirograph
        tube(radius, spiro_line_width, bottom_thick);

        // and rotational detents to prevent rotation
        translate([0,0,bottom_thick])
            detents(radius, minor_radius, bottom_thick, wall_thick);
    }
}


include <constants.scad>;
include <common_parameters.scad>;
layout="preview-generic";
if (layout=="preview-generic"){
    generic_container(box_height=box_height, 
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
        generic_lid(box_height=box_height,
                      radius=radius,
                      minor_radius=minor_radius,
                      wall_thick=wall_thick,
                      bottom_thick=bottom_thick,
                      spiro_steps=spiro_steps,
                      spiro_line_width=spiro_line_width);
}

if (layout=="box-generic"){
    generic_container(box_height=box_height,
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

if (layout=="lid-generic"){
    generic_lid(box_height=box_height,
                  radius=radius,
                  minor_radius=minor_radius,
                  wall_thick=wall_thick,
                  bottom_thick=bottom_thick,
                  spiro_steps=spiro_steps,
                  spiro_line_width=spiro_line_width);
}








