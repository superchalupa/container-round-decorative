all: box.stl lid.stl

clean:
	rm *.stl

lid.stl: box.scad
	openscad -s $@ $< -d deps-$$(basename $@ .stl).mk -Dsteps=20 -Dddebug=0 -Dlayout=\"$$(basename $@ .stl)\"

%.stl: %.scad
	openscad -s $@ $< -d deps-$$(basename $@ .stl).mk -Dsteps=20 -Dddebug=0 -Dlayout=\"$$(basename $@ .stl)\"

deps-%.mk: %.stl

-include deps-box.mk
-include deps-lid.mk

