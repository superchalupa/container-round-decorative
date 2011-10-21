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

steps=20;

radius=35;
lineWidth=1.5;
bottomThick=3;
bracelet_thick=30;
smidgen = 0.1;

module box() {
    union() {
        translate([0,0,bracelet_thick/2])
        difference() {
	        difference() {
		        squishedHollowTorus(radius, 5, bracelet_thick/2, 2);
		        translate([0,0,-bracelet_thick/2-smidgen])cylinder(h=bracelet_thick+2*smidgen,r=radius,$fn=36);
                translate([0,0,bracelet_thick/2-1]) cylinder(h=10,r=radius+10);
	        }
    	    for (i=[0:19]) {
    		    rotate([60,0,i*18])translate([-1,0,0])rotate([0,90,0])scale([0.5,2,2])cylinder(25,3,3,$fn=24);
    		    rotate([60,0,i*18+11])translate([-1,0,12])rotate([0,90,0])scale([0.5,2,2])cylinder(25,3,3,$fn=24);
    		    rotate([60,0,i*18-11])translate([-1,0,-12])rotate([0,90,0])scale([0.5,2,2])cylinder(25,3,3,$fn=24);
    		    rotate([60,0,i*18+5.5])translate([-1,0,-18])rotate([0,90,0])scale([0.4,0.75,0.75])cylinder(70,3,3,$fn=24);
    		    rotate([60,0,i*18-5.5])translate([-1,0,18])rotate([0,90,0])scale([0.4,0.75,0.75])cylinder(70,3,3,$fn=24);
    	    }
        // Make the hole in the side for the pin
        translate([radius-2,0,bracelet_thick/2-1 + smidgen])
            rotate([180,0,0])
                pinhole(h=10,r=4,lh=3,lt=1);
       
        }

        // the bottom spiro graph
        spiro(radius/2 + 0.5, lineWidth, bottomThick, steps);
        cylinder(h=1,r=radius+1);
        tube(radius+1, lineWidth, bottomThick);

        translate([radius-2,0,0])
        difference() {
            cylinder(h=bracelet_thick-1,r1=4, r2=7);
            translate([0,0,bracelet_thick-1])
                rotate([180,0,0])
                    pinhole(h=10,r=4,lh=3,lt=1);
        }
    }
}

module box_lid() {
    union() {
        spiro(radius/2 + 0.5, lineWidth, bottomThick, steps);
        translate([radius-2,0,0])
            cylinder(h=bottomThick+1,r=4);
        translate([radius-2,0,bottomThick])
            pin(h=10,r=4,lh=3,lt=1);
    }
}

if (layout=="preview"){
    box();
    #translate([0,0,bracelet_thick-1+bottomThick])
        rotate([180,0,0])
            box_lid();
}

if (layout=="box"){
    box();
}

if (layout=="lid"){
    box_lid();
}

