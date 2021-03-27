// adapted from variable_fan_adapter by Sherif Eid
use <scad-utils/transformations.scad>
use <scad-utils/shapes.scad>
use <list-comprehension-demos/skin.scad>

// all units in mm

// used all over
wall_thickness = 4;
// diameter of narrow part of funnel.
influx_diameter = 33;
influx_length = 30;
cone_height = 60;

fan_diameter = 120;
fan_thickness = 26;
fan_screw_spread = 105;
fan_screw_diameter = 4.3;

outflow_length = wall_thickness;
outflow_diameter = 130;
outflow_screw_spread = 115;

window_offset = 10;
louver_thickness = 3;
louver_length = 30;
louver_spacing = 20;

// other advanced variables
// used to control the resolution of all arcs 
$fn = 50;


// modules library
module roundrect(d) {
        minkowski() {
        square([d*0.9,d*0.9,], center=true);
        circle(r=d*0.05);
    }
}

module each_corner(d) {
    translate([d,d,0]) children(0);
    rotate([0,0,90]) translate([d,d,0]) children(0);
    rotate([0,0,180]) translate([d,d,0]) children(0);
    rotate([0,0,270]) translate([d,d,0]) children(0);
}

module fan_plate(fd=fan_diameter, fss=fan_screw_spread) {
    difference() {
        linear_extrude(height=wall_thickness){
            minkowski() {
                square(fd, center=true);
                circle(r=wall_thickness);
            }
        }
        each_corner(fss/2) {
            cylinder(d=fan_screw_diameter, h=wall_thickness);
        }
    }
}

// origin is center-x
module louver() {
    translate([outflow_diameter/-2,0,0])  {
        difference() {
            rotate([40, 0, 0]) {
                translate([0,-1*louver_length,0]) cube([outflow_diameter, louver_length*2, louver_thickness]);
            }
            mirror([0,0,1]) translate([0,outflow_diameter/-2,0])  cube(outflow_diameter);
        }
    }
}


module horn(fn=30,r1=fan_diameter/2,r2=influx_diameter/2,R = fan_diameter/2)
{
    skin([for(f=[0:1/fn:1]) 
        transform(rotation([0,90*f,0])*translation([-R,0,0]), 
            circle(r1+(r2-r1)*(1-(1-f)*(1-f))))]);
    rotate([0,90,0]) translate([-R,0,0]) cylinder(r=r2, h=influx_length);
}


// influx plate and cone
difference() {
    union() {
        rotate([0,0,45]){ fan_plate(); }
        rotate([0,0,90]) translate([fan_diameter/2,0,0]) horn();
        // cylinder(h=cone_height, d1=fan_diameter, d2=influx_diameter);
    }
    // cylinder(h=cone_height, d1=fan_diameter-2*wall_thickness, d2=influx_diameter-wall_thickness*2);
    rotate([0,0,90]) translate([fan_diameter/2,0,0]) horn(r1=fan_diameter/2-wall_thickness, r2=influx_diameter/2-wall_thickness);
}

// // influx tube
// translate([0,0,cone_height]) difference() {
//     cylinder(h=influx_length, d=influx_diameter);
//     cylinder(h=influx_length, d=influx_diameter-2*wall_thickness);
// }

mirror([0,0,1]) union() {
    // fan box
    rotate([0, 0, 45]) {
        translate([0,0,-1*wall_thickness]) {
            fan_box_length = wall_thickness*2 + fan_thickness;
            difference() {
                linear_extrude(height=fan_box_length){
                    minkowski() {
                        square(fan_diameter, center=true);
                        circle(r=wall_thickness);
                    }
                }
                linear_extrude(height=fan_box_length){
                    // roundrect(fan_diameter);
                    square(fan_diameter, center=true);
                }
                translate([fan_diameter/-2,fan_diameter*-1,wall_thickness]) {
                    cube([fan_diameter, fan_diameter, fan_thickness]);
                }

            }

        }    
    }
    

    // outflow plate and shroud
    translate([0,0,fan_thickness]) difference() {
        shroud_length = wall_thickness + outflow_length;
        union() {
            rotate([0, 0, 45]) { fan_plate(); }
            translate([0,0,wall_thickness+outflow_length-wall_thickness]) {
                fan_plate(outflow_diameter, outflow_screw_spread);            
            }
            cylinder(h=shroud_length, d1=fan_diameter, d2=outflow_diameter);
        }
        cylinder(h=shroud_length, d1=fan_diameter-2*wall_thickness, d2=outflow_diameter-2*wall_thickness);
    }

    // outer plate and louver
    translate([0,0,fan_thickness+wall_thickness+outflow_length+window_offset]) {
        // main louver
        border_height = louver_length/1.5;
        difference() {
            union() {
                // outer plate with hole
                difference() {
                    fan_plate(outflow_diameter, outflow_screw_spread);            
                    cylinder(h=wall_thickness, d1=outflow_diameter-2*wall_thickness, d2=outflow_diameter);
                }

                // louver fins
                for(n=[outflow_diameter/-2:louver_spacing:outflow_diameter/2-louver_spacing]) {
                    translate([0,n,0]) louver();
                }
                // borders on each side
                translate([outflow_diameter/-2, outflow_diameter/-2, 0]) cube([louver_thickness,outflow_diameter,border_height]);
                translate([outflow_diameter/2-louver_thickness, outflow_diameter/-2, 0]) cube([louver_thickness,outflow_diameter,border_height]);

                // screw shields, outer
                translate([0,0,wall_thickness]) each_corner(outflow_screw_spread/2) {
                    cylinder(r=fan_screw_diameter*2+louver_thickness, h=border_height-wall_thickness);
                }

            }
            // screw shields, inner
            translate([0,0,wall_thickness]) each_corner(outflow_screw_spread/2) {
                union() {
                    cylinder(r=fan_screw_diameter*2, h=border_height*2);
                    b=50;
                    rotate([0,0,45]) translate([0,b/-2,0]) cube([b,b,b]);
                }
            }
        }        
    }
}



// https://stackoverflow.com/questions/28842419/linear-rotational-extrude-at-the-same-time 


// lexan/plexi 40in x 8in
// cut in half
// 2 pairs of plates to join them


