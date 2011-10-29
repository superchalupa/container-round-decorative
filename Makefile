LATCH_STL := lid-latches.stl box-latches.stl preview-latches.stl
PIN_STL := lid-pin.stl box-pin.stl preview-pin.stl

all: $(LATCH_STL) $(PIN_STL)

-include $(LATCH_STL:.stl=.dep)
-include $(PIN_STL:.stl=.dep)
-include bracelet.dep
-include holes.dep

$(LATCH_STL): latch_container.scad
	time openscad -d $(basename $@).dep -o $@ $< -Dlayout=\"$(basename $@)\"

$(PIN_STL): pin_container.scad
	time openscad -d $(basename $@).dep -o $@ $< -Dlayout=\"$(basename $@)\"

bracelet.stl: bracelet.scad
holes.stl: holes.scad

pins.scad:
	sh ./get_thing.sh 10541
	ln -s Pin\ Connectors\ V2\ by\ tbuser\ -\ Thingiverse\:10541/pins.scad ./pins.scad

clean:
	rm *.stl *.gcode

%.stl: %.scad
	time openscad -d $(basename $@).dep -o $@ $< -Dlayout=\"$(basename $@)\"
