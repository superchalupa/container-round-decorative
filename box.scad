debug=1;
layout="preview";

echo ("Running build");
echo (layout);
echo (debug);

use <pins.scad>;

module squishedSolidTorus(major_r, minor_r1, minor_r2) {
	rotate_extrude(convexity = 10, $fn = 144)
	    translate([major_r, 0, 0])
	        scale([minor_r1,minor_r2,minor_r2]) circle(r = 1, $fn = 144);
}

module squishedHollowTorus(major_r, minor_r1, minor_r2, thick) {
	difference() {
		squishedSolidTorus(major_r, minor_r1,       minor_r2);
		squishedSolidTorus(major_r, minor_r1-thick, minor_r2-thick);
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

smidgen = 0.1;

module holySquishedHollowTorus(box_height, radius, wall_thick, bottom_buffer) {
    oval_maj_rad=6;
    distance_between=1;
    rotate_angle = 60;
    num_around = 22;
    y_step = sin(rotate_angle) * (oval_maj_rad*2+distance_between);
    num_big_ovals = floor((box_height-(bottom_buffer+1)*2)/y_step);
    degrees_per_y =  360 * tan(90-rotate_angle) / (2 * 3.141592 * radius);
    leftover = box_height - (num_big_ovals*12);
    echo ("y_step: ", y_step);
    echo ("num big ovals: ", num_big_ovals);
    echo ("degrees_per_y", degrees_per_y);
    echo ("leftover", leftover);

    translate([0,0,box_height/2])
    difference() {
        squishedHollowTorus(radius, 5, box_height/2, wall_thick);

        // Ok, this was a pain to come up with, but basically here we chop holes in the sides
        // outer loop chops the individual layers
        for (i=[0:num_around-1]) {
            // first row
            for (j=[0:num_big_ovals-1]) {
                rotate([0,0,i*(360/num_around)+j*(degrees_per_y*y_step)])
                    translate([0,0,-box_height/2 + leftover/2 + y_step/2 + j*y_step])
                        rotate([rotate_angle,0,0])
                        rotate([0,90,0])
                            scale([1.5,oval_maj_rad,1])
                                cylinder(h=radius*2,r=1,$fn=24);
            }

            // The 'odd' row (starts with half oval, but we skip that in this loop)
            for (j=[0:num_big_ovals-2]) {
                rotate([0,0,(i+0.5)*(360/num_around)+j*(degrees_per_y*y_step)+degrees_per_y*y_step/2])
                    translate([0,0,-box_height/2 + leftover/2 + y_step + j*y_step])
                        rotate([rotate_angle,0,0])
                        rotate([0,90,0])
                            scale([1.5,oval_maj_rad,1])
                                cylinder(h=radius*2,r=1,$fn=24);
            }

            // here we get the odd half-sized ones on the bottom
            // uses same formula as above, but I simplified couple terms manually
            rotate([0,0,(i+0.5)*(360/num_around)-degrees_per_y*y_step/4])
                translate([0,0,-box_height/2 + leftover/2 + y_step/4])
                rotate([rotate_angle,0,0])
                rotate([0,90,0])
                scale([1.5,oval_maj_rad/2,1])
                cylinder(h=radius*2,r=1,$fn=24);

            // here we get the odd half-sized ones on the top
            // uses same formula as above, but I simplified couple terms manually
            rotate([0,0,(i+0.5)*(360/num_around)+(num_big_ovals-1)*(degrees_per_y*y_step)+degrees_per_y*y_step/4])
                translate([0,0,-box_height/2 + leftover/2 + y_step + (num_big_ovals-1)*y_step - y_step/4])
                rotate([rotate_angle,0,0])
                rotate([0,90,0])
                scale([1.5,oval_maj_rad/2,1])
                cylinder(h=radius*2,r=1,$fn=24);
        }
    }
}

module container(box_height, radius, wall_thick, bottom_thick, spiro_steps, spiro_line_width) {
    union() {
        difference() {
            holySquishedHollowTorus(box_height, radius, wall_thick, bottom_thick);
            translate([0,0,-smidgen])cylinder(h=box_height+2*smidgen,r=radius,$fn=36);
            translate([0,0,box_height-bottom_thick]) cylinder(h=bottom_thick+10,r=radius+10);

            // Make the hole in the side for the pin
            translate([radius-2,0,box_height/2-bottom_thick])
                rotate([180,0,0])
                    pinhole(h=10,r=4,lh=3,lt=1);
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

            translate([0,0,box_height-10-tan(90-55)*7])
                rotate([0,55,0])
                translate([-box_height,-box_height,-box_height])
                cube([box_height*2,box_height*2,box_height]);

            translate([0,0,box_height-1])
                rotate([180,0,0])
                    pinhole(h=10,r=4,lh=3,lt=1);
        }
    }
}

module container_lid(box_height, radius, bottom_thick, spiro_steps, spiro_line_width) {
    union() {
        translate([0,0,box_height/2])
        difference() {
            squishedHollowTorus(radius, 5, box_height/2, 2);
            translate([0,0,-box_height/2-smidgen])cylinder(h=box_height+2*smidgen,r=radius,$fn=36);
            translate([0,0,-box_height/2+bottom_thick]) cylinder(h=box_height,r=radius+10);
        }
        spiro(radius/2 + 0.5, spiro_line_width, bottom_thick, spiro_steps);
        translate([radius-2,0,0])
            cylinder(h=bottom_thick+1,r=4);
        translate([radius-2,0,bottom_thick])
            pin(h=10,r=4,lh=3,lt=1);
        tube(radius+1, spiro_line_width, bottom_thick);
    }
}




box_height=70;
radius=40;
wall_thick=2;
spiro_steps=6;
bottom_thick=3;
spiro_line_width=1.5;

if (layout=="preview"){
    container(box_height=box_height, radius=radius, wall_thick=wall_thick, bottom_thick=bottom_thick, spiro_steps=spiro_steps, spiro_line_width=spiro_line_width);
    #translate([0,0,box_height])
        rotate([180,0,0])
            container_lid(box_height=box_height, radius=radius, bottom_thick=bottom_thick, spiro_steps=spiro_steps, spiro_line_width=spiro_line_width);
}

if (layout=="box"){
    container(box_height=box_height, radius=radius, wall_thick=wall_thick, bottom_thick=bottom_thick, spiro_steps=spiro_steps, spiro_line_width=spiro_line_width);
}

if (layout=="lid"){
    container_lid(box_height=box_height, radius=radius, bottom_thick=bottom_thick, spiro_steps=spiro_steps, spiro_line_width=spiro_line_width);
}

