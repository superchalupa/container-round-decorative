production=0;

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


steps=6;
if ( production )
{
    steps=20;
}

radius=35;
lineWidth=1.5;
bottomThick=3;
bracelet_thick=30;
smidgen = 0.1;

union() {
    translate([0,0,bracelet_thick/2])
    difference() {
	    difference() {
		    squishedHollowTorus(radius, 5, bracelet_thick/2, 2);
		    translate([0,0,-bracelet_thick/2-smidgen])cylinder(h=bracelet_thick+2*smidgen,r=radius,$fn=36);
            translate([0,0,bracelet_thick/2-1]) cylinder(h=10,r=radius+10);
	    }
if(production) {
    	for (i=[0:19]) {
    		rotate([60,0,i*18])translate([-1,0,0])rotate([0,90,0])scale([0.5,2,2])cylinder(25,3,3,$fn=24);
    		rotate([60,0,i*18+11])translate([-1,0,12])rotate([0,90,0])scale([0.5,2,2])cylinder(25,3,3,$fn=24);
    		rotate([60,0,i*18-11])translate([-1,0,-12])rotate([0,90,0])scale([0.5,2,2])cylinder(25,3,3,$fn=24);
    		rotate([60,0,i*18+5.5])translate([-1,0,-18])rotate([0,90,0])scale([0.4,0.75,0.75])cylinder(70,3,3,$fn=24);
    		rotate([60,0,i*18-5.5])translate([-1,0,18])rotate([0,90,0])scale([0.4,0.75,0.75])cylinder(70,3,3,$fn=24);
    	}
}
    }

    spiro(radius/2 + 0.5, lineWidth, bottomThick, steps);
    cylinder(1,radius+smidgen);
    tube(radius+1, lineWidth, bottomThick);
}
