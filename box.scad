layout="preview";
echo ("Running build for layout", layout);

use <container_module.scad>;

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

