all: lid.stl box.stl bracelet.stl
lid.stl: box.scad
	openscad -o $@ $< -Dlayout=\"$$(basename $@ .stl)\"

box.stl: box.scad container_module.scad
bracelet.scad box.scad: container_module.scad
container_module.scad: pins.scad
pins.scad:
	sh ./get_thing.sh 10541
	ln -s Pin\ Connectors\ V2\ by\ tbuser\ -\ Thingiverse\:10541/pins.scad ./pins.scad

clean:
	rm *.stl *.gcode

%.stl: %.scad
	openscad -o $@ $< -Dlayout=\"$$(basename $@ .stl)\"
