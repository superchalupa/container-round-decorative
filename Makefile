ALL_BOX_STLS := holes.stl lid-latches.stl lid-pin.stl box-latches.stl box-pin.stl preview-latches.stl preview-pin.stl
all: $(ALL_BOX_STLS) bracelet.stl

$(ALL_BOX_STLS): box.scad
	openscad -o $@ $< -Dlayout=\"$$(basename $@ .stl)\"

bracelet.scad box.scad: container_module.scad
box.cad: container_module.scad
container_module.scad: pins.scad

pins.scad:
	sh ./get_thing.sh 10541
	ln -s Pin\ Connectors\ V2\ by\ tbuser\ -\ Thingiverse\:10541/pins.scad ./pins.scad

clean:
	rm *.stl *.gcode

%.stl: %.scad
	openscad -o $@ $< -Dlayout=\"$$(basename $@ .stl)\"
