module squished_solid_torus(major_r, minor_r1, height) {
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

