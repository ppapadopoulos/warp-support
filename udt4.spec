Summary: udt4
Name: udt4
Version: 4.11
Release: 1
License: BSD 
Vendor: Northwestern University 
Group: System Environment/Base
Source: %{name}-%{version}.tar.gz
%define _topdir %(echo $PWD)/

%description
UDT is a reliable UDP based application level data transport protocol for 
distributed data intensive applications over wide area high-speed networks.
UDT uses UDP to transfer bulk data with its own reliability control 
and congestion control mechanisms. The new protocol can transfer data at a 
much higher speed than TCP does. UDT is also a highly configurable 
framework that can accommodate various congestion control algorithms.
%prep
%setup -n %{name}
%build
printf "\n\n\n### build ###\n\n\n"
make  -e os=LINUX arch=AMD64

%install
printf "\n\n\n### install ###\n\n\n"

ROOT=$RPM_BUILD_ROOT
TAR=/bin/tar 
INSTALL=/usr/bin/install 
APPS="sendfile recvfile appclient appserver"

echo $RPM_BUILD_ROOT 

mkdir -p $ROOT
mkdir -p $ROOT/usr/lib64
mkdir -p $ROOT/usr/include/udt
mkdir -p $ROOT/usr/bin
mkdir -p $ROOT/usr/share/$RPM_PACKAGE_NAME
		
pushd doc 
$TAR cf - * | (cd $ROOT/usr/share/$RPM_PACKAGE_NAME; $TAR xvfBp -)
popd 
$INSTALL -m 644 *.txt $ROOT/usr/share/$RPM_PACKAGE_NAME
cd src;
$INSTALL -m 644 *.h $ROOT/usr/include/udt
$INSTALL -m 644 *.so $ROOT/usr/lib64
$INSTALL -m 644 *.a  $ROOT/usr/lib64
cd ../app
$INSTALL -m 755 $APPS $ROOT/usr/bin 

%files 
/usr/lib64/*
/usr/include/*
/usr/bin/*
/usr/share/%{name}

