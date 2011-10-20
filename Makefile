%.stl: %.scad
	openscad -s $@ $< -d deps.mk -Dproduction=1 -Dlayout=$$(basename $@ .stl)

