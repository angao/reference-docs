WEBROOT=~/src/github.com/kubernetes/website
K8SROOT=~/src/github.com/kubernetes/kubernetes
MINOR_VERSION=9

APISRC=gen-apidocs/generators/build
APIDST=$(WEBROOT)/docs/reference/generated/kubernetes-api/v1.$(MINOR_VERSION)
APISRCFONT=$(APISRC)/node_modules/font-awesome
APIDSTFONT=$(APIDST)/node_modules/font-awesome

default:
	echo "Support commands:\ncli api copycli copyapi updateapispec"

brodocs:
	docker build . -t pwittrock/brodocs
	docker push pwittrock/brodocs

updateapispec:
	cp $(K8SROOT)/api/openapi-spec/swagger.json gen-apidocs/generators/openapi-spec/swagger.json

# Build kubectl docs
cleancli:
	rm -f main
	rm -rf $(shell pwd)/gen-kubectldocs/generators/includes
	rm -rf $(shell pwd)/gen-kubectldocs/generators/build
	rm -rf $(shell pwd)/gen-kubectldocs/generators/manifest.json

cli: cleancli
	go run gen-kubectldocs/main.go --kubernetes-version v1_$(MINOR_VERSION)
	docker run -v $(shell pwd)/gen-kubectldocs/generators/includes:/source -v $(shell pwd)/gen-kubectldocs/generators/build:/build -v $(shell pwd)/gen-kubectldocs/generators/:/manifest pwittrock/brodocs

copycli: cli
	rm -rf gen-kubectldocs/generators//build/documents/
	rm -rf gen-kubectldocs/generators//build/runbrodocs.sh
	rm -rf gen-kubectldocs/generators//build/manifest.json
	rm -rf $(WEBROOT)/docs/user-guide/kubectl/v1.$(MINOR_VERSION)/*
	cp -r gen-kubectldocs/generators//build/* $(WEBROOT)/docs/user-guide/kubectl/v1.$(MINOR_VERSION)/

api: cleanapi
	go run gen-apidocs/main.go --config-dir=gen-apidocs/generators --munge-groups=false
	docker run -v $(shell pwd)/gen-apidocs/generators/includes:/source -v $(shell pwd)/gen-apidocs/generators/build:/build -v $(shell pwd)/gen-apidocs/generators/:/manifest pwittrock/brodocs

# Build api docs
cleanapi:
	rm -f main
	rm -rf $(shell pwd)/gen-apidocs/generators/build
	rm -rf $(shell pwd)/gen-apidocs/generators/includes
	rm -rf $(shell pwd)/gen-apidocs/generators/manifest.json
	rm -rf $(shell pwd)/gen-apidocs/generators/includes/_generated_*

copyapi:
	cp $(APISRC)/index.html $(APIDST)/index.html
	cp $(APISRC)/navData.js $(APIDST)/navData.js
	cp $(APISRC)/scroll.js $(APIDST)/scroll.js
	cp $(APISRC)/stylesheet.css $(APIDST)/stylesheet.css
	cp $(APISRC)/tabvisibility.js $(APIDST)/tabvisibility.js
	cp $(APISRC)/node_modules/bootstrap/dist/css/bootstrap.min.css $(APIDST)/node_modules/bootstrap/dist/css/bootstrap.min.css
	cp $(APISRC)/node_modules/highlight.js/styles/default.css $(APIDST)/node_modules/highlight.js/styles/default.css
	cp $(APISRC)/node_modules/jquery.scrollto/jquery.scrollTo.min.js $(APIDST)/node_modules/jquery.scrollto/jquery.scrollTo.min.js
	cp $(APISRC)/node_modules/jquery/dist/jquery.min.js $(APIDST)/node_modules/jquery/dist/jquery.min.js
	cp $(APISRCFONT)/css/font-awesome.css $(APIDSTFONT)/css/font-awesome.css
	cp $(APISRCFONT)/css/font-awesome.css.map $(APIDSTFONT)/css/font-awesome.css.map
	cp $(APISRCFONT)/css/font-awesome.min.css $(APIDSTFONT)/css/font-awesome.min.css
	cp $(APISRCFONT)/fonts/FontAwesome.otf $(APIDSTFONT)/fonts/FontAwesome.otf	
	cp $(APISRCFONT)/fonts/fontawesome-webfont.eot $(APIDSTFONT)/fonts/fontawesome-webfont.eot
	cp $(APISRCFONT)/fonts/fontawesome-webfont.svg $(APIDSTFONT)/fonts/fontawesome-webfont.svg
	cp $(APISRCFONT)/fonts/fontawesome-webfont.ttf $(APIDSTFONT)/fonts/fontawesome-webfont.ttf
	cp $(APISRCFONT)/fonts/fontawesome-webfont.woff $(APIDSTFONT)/fonts/fontawesome-webfont.woff
	cp $(APISRCFONT)/fonts/fontawesome-webfont.woff2 $(APIDSTFONT)/fonts/fontawesome-webfont.woff2

# Build resource docs
resource: cleanapi
	go run gen-apidocs/main.go --build-operations=false --munge-groups=false --config-dir=gen-apidocs/generators
	docker run -v $(shell pwd)/gen-apidocs/generators/includes:/source -v $(shell pwd)/gen-apidocs/generators/build:/build -v $(shell pwd)/gen-apidocs/generators/:/manifest pwittrock/brodocs

copyresource: resource
	rm -rf gen-apidocs/generators/build/documents/
	rm -rf gen-apidocs/generators/build/runbrodocs.sh
	rm -rf gen-apidocs/generators/build/manifest.json
	rm -rf $(WEBROOT)/docs/resources-reference/v1.$(MINOR_VERSION)/*
	cp -r gen-apidocs/generators/build/* $(WEBROOT)/docs/resources-reference/v1.$(MINOR_VERSION)/
