all: lid.stl box.stl

clean:
	rm *.stl

lid.stl: box.scad
	openscad -s $@ $< -d deps-$$(basename $@ .stl).mk -Dsteps=20 -Dddebug=0 -Dlayout=\"$$(basename $@ .stl)\" -Dnum_divisions_around=20

%.stl: %.scad
	openscad -s $@ $< -d deps-$$(basename $@ .stl).mk -Dsteps=20 -Dddebug=0 -Dlayout=\"$$(basename $@ .stl)\" -Dnum_divisions_around=20

deps-%.mk: %.stl

-include deps-box.mk
-include deps-lid.mk

