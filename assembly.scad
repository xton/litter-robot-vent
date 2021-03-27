// adapted from variable_fan_adapter by Sherif Eid

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
outflow_screw_diameter = 115;

// internal parameters
// pipe reduction ratio relative to fan 1 diameter
n_pipe = 1;
// angle factor
n_angle = 0.501;

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
    translate([-1*d,d,0]) children(0);
    translate([d,-1*d,0]) children(0);
    translate([-1*d,-1*d,0]) children(0);
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

// influx plate and cone
difference() {
    union() {
        rotate([0,0,45]){ fan_plate(); }
        cylinder(h=cone_height, d1=fan_diameter, d2=influx_diameter);
    }
    cylinder(h=cone_height, d1=fan_diameter-2*wall_thickness, d2=influx_diameter-wall_thickness*2);
}

// influx tube
translate([0,0,cone_height]) difference() {
    cylinder(h=influx_length, d=influx_diameter);
    cylinder(h=influx_length, d=influx_diameter-2*wall_thickness);
}

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
                translate([fan_diameter/-2,0,wall_thickness]) {
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
                fan_plate(outflow_diameter, outflow_screw_diameter);            
            }
            cylinder(h=shroud_length, d1=fan_diameter, d2=outflow_diameter);
        }
        cylinder(h=shroud_length, d1=fan_diameter-2*wall_thickness, d2=outflow_diameter-2*wall_thickness);
    }
}


// lexan/plexi 40in x 8in
// cut in half
// 2 pairs of plates to join them

