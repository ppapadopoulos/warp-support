include *.mk

COMMA = ,
ALLPACKS = $(BOOTPACKS) $(PYPACKS)
MYPACKS = $(foreach tgt, $(ALLPACKS), $(word 1, $(subst $(COMMA), ,$(tgt))) )
MYBOOTPACKS = $(foreach tgt, $(BOOTPACKS), $(word 1, $(subst $(COMMA), ,$(tgt))) )

GENERICSPEC = generic.spec.in

RPMDIRS = SOURCES BUILD SRPMS RPMS BUILDROOT

$(RPMDIRS):
	mkdir $@

rpms: $(MYBOOTPACKS) $(MYPACKS)

$(MYPACKS): $(RPMDIRS)
	(TGT=$(filter $@%,$(ALLPACKS)); 								\
	 VERSION=$$(echo $$TGT | cut -d, -f 2) ;						\
	cat $(GENERICSPEC)| sed -e  "s/@TGT@/$@/" -e "s/@VERSION@/$$VERSION/" > $@.spec; 	\
	cp $@-$$VERSION.tar.gz SOURCES ; 							\
	rpmbuild -ba --buildroot=$(PWD)/BUILDROOT $@.spec ;					\
	echo "$@ $$VERSION" )

bootstrap: $(MYBOOTPACKS)
	for pkg in $(MYBOOTPACKS); do 				\
		yum install RPMS/x86_64/*$$pkg*rpm; done 

clean:
	/bin/rm -rf $(RPMDIRS)
	/bin/rm *spec
	
