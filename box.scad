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

module tube(outside_r,lineWidth,length) {
    translate([0,0,length/2])
	difference() {
		cylinder(length,outside_r,outside_r,center=true);
		cylinder(length+0.2,outside_r-lineWidth,outside_r-lineWidth,center=true);
	}
}

module spiro(radius, lineWidth, height, steps) {
    for (i=[0:steps-1]) {
        rotate([0,0,i*360/steps])
            translate([radius,0,0]) tube(radius,lineWidth,height);
    }
}

lineWidth=1.5;
bottomThick=3;
smidgen = 0.1;

module box(box_height, radius, wall_thick, spiro_steps) {
    num_big_ovals = floor((box_height-8)/12);
    y_step = 12;
    num_around = 20;
    rotate_angle = 60;
    degrees_per_y =  360 * tan(90-rotate_angle) / (2 * 3.141592 * radius);
    leftover = box_height - (num_big_ovals*12);
    echo ("num big ovals: ", num_big_ovals);
    echo ("degrees_per_y", degrees_per_y);
    echo ("leftover", leftover);
    union() {
        translate([0,0,box_height/2])
        difference() {
	        difference() {
		        squishedHollowTorus(radius, 5, box_height/2, wall_thick);
		        translate([0,0,-box_height/2-smidgen])cylinder(h=box_height+2*smidgen,r=radius,$fn=36);
                translate([0,0,box_height/2-bottomThick]) cylinder(h=10,r=radius+10);
	        }

    	    for (i=[0:num_around-1]) {
                for (j=[0:num_big_ovals-1]) {
    		        rotate([0,0,i*(360/num_around)+j*(degrees_per_y*y_step)])
                        translate([0,0,-box_height/2 + leftover/2 + y_step/2 + j*y_step])
                            rotate([rotate_angle,0,0])
                            rotate([0,90,0])
                                scale([1.5,6,1])
                                    cylinder(h=radius*2,r=1,$fn=24);
                }

                for (j=[0:num_big_ovals-2]) {
    		        rotate([0,0,(i+0.5)*(360/num_around)+j*(degrees_per_y*y_step)+degrees_per_y*y_step/2])
                        translate([0,0,-box_height/2 + leftover/2 + y_step + j*y_step])
                            rotate([rotate_angle,0,0])
                            rotate([0,90,0])
                                scale([1.5,6,1])
                                    cylinder(h=radius*2,r=1,$fn=24);
                }

    		     rotate([0,0,(i+0.5)*(360/num_around)-degrees_per_y*y_step/4])
                        translate([0,0,-box_height/2 + leftover/2 + y_step/4])
                        rotate([rotate_angle,0,0])
                        rotate([0,90,0])
                            scale([1.5,3,1])
                                cylinder(h=radius*2,r=1,$fn=24);

    		     rotate([0,0,(i+0.5)*(360/num_around)+(num_big_ovals-1)*(degrees_per_y*y_step)+degrees_per_y*y_step/4])
                        translate([0,0,-box_height/2 + leftover/2 + y_step + (num_big_ovals-1)*y_step - y_step/4])
                        rotate([rotate_angle,0,0])
                        rotate([0,90,0])
                            scale([1.5,3,1])
                                cylinder(h=radius*2,r=1,$fn=24);

    	    }
        // Make the hole in the side for the pin
        translate([radius-2,0,box_height/2-bottomThick])
            rotate([180,0,0])
                pinhole(h=10,r=4,lh=3,lt=1);
       
        }

        // the bottom spiro graph
        spiro(radius/2 + 0.5, lineWidth, bottomThick, spiro_steps);
        cylinder(h=1,r=radius+1);
        tube(radius+1, lineWidth, bottomThick);

        translate([radius-2,0,0])
        difference() {
            cylinder(h=box_height-bottomThick,r1=4, r2=7);
            translate([0,0,box_height-1])
                rotate([180,0,0])
                    pinhole(h=10,r=4,lh=3,lt=1);
        }
    }
}

module box_lid(box_height, radius, spiro_steps) {
    union() {
        translate([0,0,box_height/2])
        difference() {
            squishedHollowTorus(radius, 5, box_height/2, 2);
            translate([0,0,-box_height/2-smidgen])cylinder(h=box_height+2*smidgen,r=radius,$fn=36);
            translate([0,0,-box_height/2+bottomThick]) cylinder(h=box_height,r=radius+10);
        }
        spiro(radius/2 + 0.5, lineWidth, bottomThick, spiro_steps);
        translate([radius-2,0,0])
            cylinder(h=bottomThick+1,r=4);
        translate([radius-2,0,bottomThick])
            pin(h=10,r=4,lh=3,lt=1);
        tube(radius+1, lineWidth, bottomThick);
    }
}

box_height=65;
radius=35;
wall_thick=2;
spiro_steps=6;

if (layout=="preview"){
    box(box_height=box_height, radius=radius, wall_thick=wall_thick, spiro_steps=spiro_steps);
    #translate([0,0,box_height])
        rotate([180,0,0])
            box_lid(box_height=box_height, radius=radius, spiro_steps=spiro_steps);
}

if (layout=="box"){
    box(box_height=box_height, radius=radius, wall_thick=wall_thick, spiro_steps=spiro_steps);
}

if (layout=="lid"){
    box_lid(box_height=box_height, radius=radius, spiro_steps=spiro_steps);
}

