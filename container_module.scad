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
	    rotate_extrude(convexity = 2)   // , $fa=degrees_per_mm_of_circ, $fs=1, $fn=36)
	    translate([major_r, 0, 0])

        // openscad formula for picking # of fragments to render doesnt appear
        // to work very well in the presence of scaling. So, instead of using a
        // unit circle, use a bit bigger so we get enough fragments dont be
        // confused here, circle radius (r) would normally be "1" and then
        // scaled from there (by [minor_r2,height/2,height/2]). But to get a
        // reasonable number of fragments, I'm using r=major_r, then scaling
        // from there
	    scale([minor_r1/major_r,height/(major_r*2),height/(major_r*2)]) 
        circle(r = major_r);
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
    leftover = box_height - (num_big_ovals*(hole_len+distance_between_holes));
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
                    translate([0,0,leftover/2 + y_step/2 + j*y_step])
                        rotate([hole_rotation_angle,0,0])
                        rotate([0,90,0])
                            scale([1.5/oval_maj_rad,1,1])
                                cylinder(h=radius*2,r=oval_maj_rad);
            }

            // The 'odd' row (starts with half oval, but we skip that in this loop)
            for (j=[0:num_big_ovals-2]) {
                rotate([0,0,(i+0.5)*(360/num_divisions_around)+j*(degrees_per_y*y_step)+degrees_per_y*y_step/2])
                    translate([0,0,leftover/2 + y_step + j*y_step])
                        rotate([hole_rotation_angle,0,0])
                        rotate([0,90,0])
                            scale([1.5/oval_maj_rad,1,1])
                                cylinder(h=radius*2,r=oval_maj_rad);
            }

            // here we get the odd half-sized ones on the bottom
            // uses same formula as above, but I simplified couple terms manually
            rotate([0,0,(i+0.5)*(360/num_divisions_around)-degrees_per_y*y_step/4])
                translate([0,0,leftover/2 + y_step/4])
                rotate([hole_rotation_angle,0,0])
                rotate([0,90,0])
                scale([1.5/oval_maj_rad,1/2,1])
                cylinder(h=radius*2,r=oval_maj_rad);

            // here we get the odd half-sized ones on the top
            // uses same formula as above, but I simplified couple terms manually
            rotate([0,0,(i+0.5)*(360/num_divisions_around)+(num_big_ovals-1)*(degrees_per_y*y_step)+degrees_per_y*y_step/4])
                translate([0,0,leftover/2 + y_step + (num_big_ovals-1)*y_step - y_step/4])
                rotate([hole_rotation_angle,0,0])
                rotate([0,90,0])
                scale([1.5/oval_maj_rad,1/2,1])
                cylinder(h=radius*2,r=oval_maj_rad);
        }
    }
}

module container(box_height, radius, wall_thick, bottom_thick, spiro_steps, spiro_line_width, hole_len, distance_between_holes, hole_rotation_angle, num_divisions_around) 
{
    union() {
        difference() {
            holy_squished_hollow_torus(box_height, radius, wall_thick, bottom_thick+1, hole_len, distance_between_holes, hole_rotation_angle, num_divisions_around);
            translate([0,0,-smidgen])cylinder(h=box_height+2*smidgen,r=radius);
            translate([0,0,box_height-bottom_thick-fitting_windage_snug]) cylinder(h=bottom_thick+10,r=radius+10);

            // Make the hole in the side for the pin
            translate([radius-2,0,box_height-bottom_thick])
                rotate([180,0,0])
                    pinhole(h=10,r=4,lh=3,lt=1);

            // front latch detent
            translate([0,0,box_height])
                rotate([180,0,0])
                front_latch(box_height, radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);
        }

        // the bottom spiro graph
        spiro(radius/2 + 0.5, spiro_line_width, bottom_thick, spiro_steps);
        cylinder(h=1,r=radius+1);
        tube(radius+1, spiro_line_width, bottom_thick);

        // The hole to hold the lid
        translate([radius-2,0,0])
        difference() {
            // it's a cylinder that merges into the side at 45 deg angle
            cylinder(h=box_height-bottom_thick,r1=7, r2=7);

            translate([0,0,box_height-10-tan(55)*7])
                rotate([0,55,0])
                translate([-box_height,-box_height,-box_height])
                cube([box_height*2,box_height*2,box_height]);

            translate([0,0,box_height-1])
                rotate([180,0,0])
                    pinhole(h=10,r=4,lh=3,lt=1);
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

module front_latch(box_height, radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width) {
        difference() {
            translate([-radius-wall_thick*2,-5,0])
                cube([wall_thick*2.5,10,bottom_thick*2.5]); 
            squished_solid_torus(radius, 5, box_height, 2);
        }
        translate([-radius-3*wall_thick/2+.25,0,bottom_thick*2.5-.25])
            rotate([0,45,0])
            translate([-wall_thick/2,-5,0])
            cube([wall_thick,10,1]); 
        translate([-radius-3*wall_thick/2+.25,0,bottom_thick*2.5])
            rotate([0,-45,0])
            translate([-wall_thick/2,-5,0])
            cube([wall_thick,10,1]); 
        translate([-radius-wall_thick*2,-5,bottom_thick*2.5-1])
            cube([wall_thick,10,1]); 
}

module container_lid(box_height, radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width) {
    union() {
        difference() {
            squished_hollow_torus(radius, 5, box_height, 2);
            translate([0,0,-smidgen])cylinder(h=box_height+2*smidgen,r=radius);
            translate([0,0,bottom_thick]) cylinder(h=box_height,r=radius+10);
        }

        front_latch(box_height, radius, bottom_thick, wall_thick, spiro_steps, spiro_line_width);

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


