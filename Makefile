include *.mk

## Python Packages: Format of an etnry in BOOTPACKS/PYPACKS  name,version
## See *.mk files in this directory
COMMA = ,
ALLPACKS = $(BOOTPACKS) $(PYPACKS)
MYPACKS = $(foreach tgt, $(ALLPACKS), $(word 1, $(subst $(COMMA), ,$(tgt))) )
MYBOOTPACKS = $(foreach tgt, $(BOOTPACKS), $(word 1, $(subst $(COMMA), ,$(tgt))) )
GENERICSPEC = generic.spec.in

## Python RPMS
PYTHONURL = http://beta6.rocksclusters.org/install/rolls/python/6.2/x86_64/RedHat/RPMS
PYTHONRPMS = opt-python-27-2.7.8-1.x86_64.rpm \
	     opt-python-modules-2.7.8-2.x86_64.rpm \
	     opt-setuptools-27-6.1-1.x86_64.rpm

## Udt
UDTNAME = udt4
UDTVERSION = 4.11
UDTTARFILE = $(UDTNAME)-$(UDTVERSION).tar.gz
UDTGIT = 

## Generic
RPMDIRS = SOURCES BUILD SRPMS RPMS BUILDROOT

## Help
HELPTEXT = "\
	make help       -- This message \n\
	make bootstrap  -- Build and install Cython and udt4 packages \n\
	make rpms       -- makes all rpms \n\
	make <python pkg>  -- make individual python pkg, eg. make blessings \n\
	make udtrpm	-- make the the udtrpm\n\
	make clean      -- cleans everything \n\
	"

help:
	@ echo -e $(HELPTEXT)

$(RPMDIRS):
	mkdir $@

rpms: udtrpm $(MYBOOTPACKS) $(MYPACKS)

$(MYPACKS): $(RPMDIRS)
	(TGT=$(filter $@%,$(ALLPACKS)); 								\
	 VERSION=$$(echo $$TGT | cut -d, -f 2) ;						\
	cat $(GENERICSPEC)| sed -e  "s/@TGT@/$@/" -e "s/@VERSION@/$$VERSION/" > $@.spec; 	\
	cp $@-$$VERSION.tar.gz SOURCES ; 							\
	rpmbuild -ba --buildroot=$(PWD)/BUILDROOT $@.spec ;					\
	echo "$@ $$VERSION" )



bootstrap: python27 udtrpm $(MYBOOTPACKS)
	 - for pkg in $(UDTNAME) $(MYBOOTPACKS); do	\
		yum install RPMS/x86_64/*$$pkg*rpm; done 
python27:
	 - for pkg in $(PYTHONRPMS); do \
		yum install $(PYTHONURL)/$$pkg; done

$(UDTNAME):
	git clone git://git.code.sf.net/p/udt/git $(UDTNAME)	

SOURCES/$(UDTTARFILE): $(RPMDIRS) $(UDTNAME) 
	tar czf $@ -C $(UDTNAME) $(UDTNAME)

udtrpm: SOURCES/$(UDTTARFILE)
	rpmbuild -ba --buildroot=$(PWD)/BUILDROOT $(UDTNAME).spec

	
clean:
	find . -name '*spec' -a -not -name udt4.spec -exec /bin/rm {} \; 
	/bin/rm -rf $(UDTNAME) $(RPMDIRS)
