layout="preview";
echo ("Running build for", layout);

use <pins.scad>;

// use this when subtracting surfaces and we want to make sure they dont coincide
smidgen = 0.1;

// use this when parts have to fit together 
fitting_windage_loose=0.350;
fitting_windage_snug=0.250;


module squished_solid_torus(major_r, minor_r1, height) {
    // manually calculate how many fragments to use to render circumference, 
    // as openscad gets this wrong
    circumference = (major_r+minor_r1) * 2 * 3.1415926;
    degrees_per_mm_of_circ = 360 / circumference;

    translate([0,0,height/2])
	    rotate_extrude(convexity = 2, $fs=$fs/3, $fa=$fa/3)
	    translate([major_r, 0, 0])

        // openscad formula for picking # of fragments to render doesnt appear
        // to work very well in the presence of scaling. So, instead of using a
        // unit circle, use a bit bigger so we get enough fragments dont be
        // confused here, circle radius (r) would normally be "1" and then
        // scaled from there (by [minor_r2,height/2,height/2]). But to get a
        // reasonable number of fragments, I'm using r=major_r, then scaling
        // from there
	    scale([minor_r1/major_r,height/(major_r*2),height/(major_r*2)]) 
        circle(r = major_r, $fs=$fs/1.5, $fa=$fa/1.5);
}

module squished_hollow_torus(major_r, minor_r1, height, thick) {
	difference() {
		squished_solid_torus(major_r, minor_r1,       height);
        translate([0,0,thick/2])
		    squished_solid_torus(major_r, minor_r1-thick, height-thick);
	}
}

module tube(outside_r,tube_wall_thick,length) {
    translate([0,0,length/2])
	difference() {
		cylinder(length,outside_r,outside_r,center=true);
		cylinder(length+0.2,outside_r-tube_wall_thick,outside_r-tube_wall_thick,center=true);
	}
}

module spiro(radius, spiro_line_width, height, steps) {
    for (i=[0:steps-1]) {
        rotate([0,0,i*360/steps])
            translate([radius,0,0]) tube(radius,spiro_line_width,height);
    }
}

module holy_squished_hollow_torus(box_height=35, radius=35, wall_thick=3, edge_buffer=3, hole_len=12, distance_between_holes=1, hole_rotation_angle=60, num_divisions_around=20, minor_radius=5) {
    oval_maj_rad=hole_len/2;
    y_step = sin(hole_rotation_angle) * (oval_maj_rad*2+distance_between_holes);
    num_big_ovals = floor((box_height-edge_buffer*2)/y_step);
    degrees_per_y =  360 * tan(90-hole_rotation_angle) / (2 * 3.141592 * radius);
    leftover = box_height - (num_big_ovals*(y_step));
    echo ("y_step: ", y_step);
    echo ("num big ovals: ", num_big_ovals);
    echo ("degrees_per_y_unit", degrees_per_y);
    echo ("leftover", leftover);

    difference() {
        squished_hollow_torus(radius, minor_radius, box_height, wall_thick);

        // Ok, this was a pain to come up with, but basically here we chop holes in the sides
        // outer loop copies each individual vertical 'line' around the circumference
        // inner loop does one individual 'line' of holes going up
        for (i=[0:num_divisions_around-1]) {
            // first row
            for (j=[0:num_big_ovals-1]) {
                rotate([0,0,i*(360/num_divisions_around)+j*(degrees_per_y*y_step)])
                    translate([radius-minor_radius-smidgen,0,leftover/2 + y_step/2 + j*y_step])
                    rotate([hole_rotation_angle,0,0])
                    rotate([0,90,0])
                    scale([1.5/oval_maj_rad,1,1])
                    cylinder(h=minor_radius*2+smidgen*2,r1=oval_maj_rad, r2=oval_maj_rad);
            }

            // The 'odd' row (starts with half oval, but we skip that in this loop)
            for (j=[0:num_big_ovals-2]) {
                rotate([0,0,(i+0.5)*(360/num_divisions_around)+j*(degrees_per_y*y_step)+degrees_per_y*y_step/2])
                    translate([radius-minor_radius-smidgen,0,leftover/2 + y_step + j*y_step])
                    rotate([hole_rotation_angle,0,0])
                    rotate([0,90,0])
                    scale([1.5/oval_maj_rad,1,1])
                    cylinder(h=minor_radius*2+smidgen*2,r1=oval_maj_rad, r2=oval_maj_rad);
            }

            // here we get the odd half-sized ones on the bottom
            // uses same formula as above, but I simplified couple terms manually
            rotate([0,0,(i+0.5)*(360/num_divisions_around)-degrees_per_y*y_step/4])
                translate([radius-minor_radius-smidgen,0,leftover/2 + y_step/4])
                rotate([hole_rotation_angle,0,0])
                rotate([0,90,0])
                scale([1.5/oval_maj_rad,1/2,1])
                cylinder(h=minor_radius*2+smidgen*2,r1=oval_maj_rad, r2=oval_maj_rad);

            // here we get the odd half-sized ones on the top
            // uses same formula as above, but I simplified couple terms manually
            rotate([0,0,(i+0.5)*(360/num_divisions_around)+(num_big_ovals-1)*(degrees_per_y*y_step)+degrees_per_y*y_step/4])
                translate([radius-minor_radius-smidgen,0,leftover/2 + y_step + (num_big_ovals-1)*y_step - y_step/4])
                rotate([hole_rotation_angle,0,0])
                rotate([0,90,0])
                scale([1.5/oval_maj_rad,1/2,1])
                cylinder(h=minor_radius*2+smidgen*2,r1=oval_maj_rad, r2=oval_maj_rad);
        }
    }
}

module container_with_latches(box_height, radius, minor_radius, wall_thick, bottom_thick, spiro_steps, spiro_line_width, hole_len, distance_between_holes, hole_rotation_angle, num_divisions_around) 
{
    echo ("container: minor_radius", minor_radius);
    union() {
        difference() {
            holy_squished_hollow_torus(box_height, radius, wall_thick, bottom_thick+3, hole_len, distance_between_holes, hole_rotation_angle, num_divisions_around, minor_radius);
            translate([0,0,-smidgen])cylinder(h=box_height+2*smidgen,r=radius);
            translate([0,0,box_height-bottom_thick-fitting_windage_snug]) cylinder(h=bottom_thick+10,r=radius+10);

            translate([0,0,box_height])
                rotate([180,0,0])

                container_lid_with_latches(box_height=box_height,
                      radius=radius,
                      minor_radius=minor_radius,
                      wall_thick=wall_thick,
                      bottom_thick=bottom_thick,
                      spiro_steps=spiro_steps,
                      spiro_line_width=spiro_line_width);
        }

        // the bottom spiro graph
        spiro(radius/2 + 0.4, spiro_line_width, bottom_thick, spiro_steps);
        cylinder(h=1,r=radius+0.9);
        tube(radius+1.1, spiro_line_width, bottom_thick);
    }
}


module container_with_pin(box_height, radius, minor_radius, wall_thick, bottom_thick, spiro_steps, spiro_line_width, hole_len, distance_between_holes, hole_rotation_angle, num_divisions_around) 
{
    pinhole_height = 10;
    pinhole_inside_radius = 4;
    pinhole_wall_thick=3;
    cube_s = 2*(pinhole_inside_radius+pinhole_wall_thick)*1.5; // approximate sqrt(2) = 1.5
    pin_attachment_h = pinhole_height+2*(pinhole_inside_radius+pinhole_wall_thick);
    minor_radius=5;

    union() {
        difference() {
            holy_squished_hollow_torus(box_height, radius, wall_thick, bottom_thick+3, hole_len, distance_between_holes, hole_rotation_angle, num_divisions_around, minor_radius);
            translate([0,0,-smidgen])cylinder(h=box_height+2*smidgen,r=radius);
            translate([0,0,box_height-bottom_thick-fitting_windage_snug]) cylinder(h=bottom_thick+10,r=radius+10);

            translate([0,0,box_height])
                rotate([180,0,0])
                container_lid_with_pin(box_height=box_height,
                      radius=radius,
                      minor_radius=minor_radius,
                      wall_thick=wall_thick,
                      bottom_thick=bottom_thick,
                      spiro_steps=spiro_steps,
                      spiro_line_width=spiro_line_width);
        }

        // the bottom spiro graph
        spiro(radius/2 + 0.5, spiro_line_width, bottom_thick, spiro_steps);
        cylinder(h=1,r=radius+1);
        tube(radius+1, spiro_line_width, bottom_thick);

        // The hole to hold the lid
        translate([radius-2,0,box_height-bottom_thick-pin_attachment_h])
        difference() {
            // it's a cylinder that merges into the side at 45 deg angle
            cylinder(h=pin_attachment_h,r=pinhole_inside_radius + pinhole_wall_thick);
        
            translate([0,0,pinhole_inside_radius+pinhole_wall_thick])
                rotate([0,45,0])
                translate([0,0,-(sqrt(2)*(pinhole_inside_radius+pinhole_wall_thick)-smidgen)/2])
                cube([cube_s, cube_s,sqrt(2)*(pinhole_inside_radius+pinhole_wall_thick)+smidgen], center=true);
        
            translate([0,0,pinhole_height+pin_attachment_h])
                rotate([180,0,0])
                pinhole(h=pinhole_height,r=pinhole_inside_radius,lh=3,lt=1, tight=true);
        
            cylinder(h=pin_attachment_h+1,r=pinhole_inside_radius);
        }
    }
}



module detents(radius, wall_thick,negative=0)
{
        // detents
        z_trans=negative * -1;
        translate([-wall_thick/2,radius-wall_thick/2, z_trans])
            cube( [ wall_thick,  wall_thick/2,        1]);
        translate([-wall_thick/2,-radius,             z_trans])
            cube( [ wall_thick,  wall_thick/2,        1]);
}

module latch(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width)
{
    clip_r = 7*minor_radius/12;
    clip_midpoint_h = 5;
    clip_w = 10;
    echo ("latch: minor_radius", minor_radius);
    union() {
        difference() {
            translate([-radius-minor_radius,-(clip_w/2),0])
                cube([minor_radius,clip_w,bottom_thick+clip_midpoint_h]);
            squished_solid_torus(radius, minor_radius, box_height);
        }

        translate([-radius-minor_radius,0,bottom_thick+clip_midpoint_h])
        difference() {
            rotate([90,0,0])
                cylinder(h=10,r=clip_r,center=true,$fn=10);

            translate([ -2*clip_r-smidgen,  -clip_w,  -clip_r  -smidgen])
                cube([2*clip_r, 2*clip_w, 2*clip_r+2*smidgen]);
        }
    }
}

module container_lid_with_latches(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width)
{
    echo ("lid: minor_radius", minor_radius);
    union() {

        // matching curve of box
        difference() {
            squished_solid_torus(radius, minor_radius, box_height);
            translate([0,0,-smidgen])cylinder(h=box_height+2*smidgen,r=radius);
            translate([0,0,bottom_thick]) cylinder(h=box_height,r=radius+10);
        }

        // outside tube and spirograph
        tube(radius+1, spiro_line_width, bottom_thick);
        spiro(radius/2 + 0.5, spiro_line_width, bottom_thick, spiro_steps);

        latch(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);
        rotate([0,0,180])
            latch(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);


        // detents
        translate([0,0,bottom_thick])
            detents(radius, wall_thick,negative=0);
    }
}

module container_lid_with_pin(box_height, radius, minor_radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width) {
    union() {
        difference() {
            squished_solid_torus(radius, minor_radius, box_height);
            translate([0,0,-smidgen])cylinder(h=box_height+2*smidgen,r=radius);
            translate([0,0,bottom_thick]) cylinder(h=box_height,r=radius+10);
        }

        latch(box_height, radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);
        
        // pin
        // extra cyl so we dont have coincident faces
        translate([radius-2,0,0])
            cylinder(h=bottom_thick+1,r=4);
        translate([radius-2,0,bottom_thick])
            pin(h=10,r=4,lh=3,lt=1);

        // outside tube and spirograph
        tube(radius+1, spiro_line_width, bottom_thick);
        spiro(radius/2 + 0.5, spiro_line_width, bottom_thick, spiro_steps);

        // detents
        translate([0,0,bottom_thick])
            detents(radius, wall_thick,negative=0);
    }
}


