
.PHONY: build check document install vignettes

build: document
	cd work && R CMD build ../

check: build
	cd work && R CMD check --as-cran `ls fastnetworklib*.tar.gz | sort | tail -n 1`

document:
	R -e "roxygen2::roxygenise()"

vignettes: build
	cd work && tar -xzf `ls fastnetworklib*.tar.gz | sort | tail -n 1` && \
	  rm -r -f ../inst/doc && \
	  mkdir -p ../inst && \
	  cp -r fastnetworklib/inst/doc ../inst


install: build
	R CMD INSTALL `ls work/fastnetworklib*.tar.gz | sort | tail -n 1` 


