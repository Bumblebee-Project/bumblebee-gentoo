# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit cmake-utils multilib subversion

DESCRIPTION="Run OpenGL applications remotely with full 3D hardware acceleration"
HOMEPAGE="http://www.virtualgl.org/"
ESVN_REPO_URI="https://virtualgl.svn.sourceforge.net/svnroot/virtualgl/vgl/trunk"
SRC_URI=""

SLOT="0"
LICENSE="LGPL-2.1 wxWinLL-3.1 FLTK"
KEYWORDS=""
IUSE="multilib ssl"

RDEPEND="ssl? ( dev-libs/openssl )
	media-libs/libjpeg-turbo
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXv
	multilib? ( app-emulation/emul-linux-x86-xlibs app-emulation/emul-linux-x86-baselibs )
	virtual/opengl"
DEPEND="${RDEPEND}"

CMAKE_VERBOSE=1
build32_dir="${WORKDIR}/${P}_build32"

src_prepare() {
	for file in server/vglgenkey server/vglrun server/vglserver_config doc/index.html; do
		sed -e "s#/etc/opt#/etc#g" -i ${file} || die
	done

	default
}

src_configure() {
	# Configure 32bit version on multilib
	use amd64 && use multilib && (
		einfo "Multilib build enabled!"
		einfo "Configuring 32bit libs..."

		local ABI=x86
		local CFLAGS="${CFLAGS} -m32"
		local CXXFLAGS="${CXXFLAGS} -m32"
		local LDFLAGS="${LDFLAGS} -m32"
		local CMAKE_BUILD_DIR="${build32_dir}"

		mycmakeargs=(
			$(cmake-utils_use ssl VGL_USESSL)
			-DVGL_DOCDIR=/usr/share/doc/"${P}"
			-DVGL_LIBDIR=/usr/$(get_libdir)
			-DTJPEG_INCLUDE_DIR=/usr/include
			-DTJPEG_LIBRARY=/usr/$(get_libdir)/libturbojpeg.so
			-DCMAKE_LIBRARY_PATH=/usr/lib32
			-DVGL_FAKELIBDIR=/usr/fakelib/32
		)
		cmake-utils_src_configure

		einfo "Configuring 64bit libs..."
	)

	# Configure native version
	mycmakeargs=(
		$(cmake-utils_use ssl VGL_USESSL)
		-DVGL_DOCDIR=/usr/share/doc/"${P}"
		-DVGL_LIBDIR=/usr/$(get_libdir)
		-DTJPEG_INCLUDE_DIR=/usr/include
		-DTJPEG_LIBRARY=/usr/$(get_libdir)/libturbojpeg.so
		-DCMAKE_LIBRARY_PATH=/usr/lib64
		-DVGL_FAKELIBDIR=/usr/fakelib/64
	)
	cmake-utils_src_configure
}

src_compile() {
	# Make 32bit version on multilib
	use amd64 && use multilib && (
		einfo "Building 32bit libs..."
		local CMAKE_BUILD_DIR="${build32_dir}"
		cmake-utils_src_compile

		einfo "Building 64bit libs..."
	)

	# Make native version
	cmake-utils_src_compile
}

src_install() {
	# Install 32bit version on multilib
	use amd64 && use multilib && (
		einfo "Installing 32bit libs..."
		local CMAKE_BUILD_DIR="${build32_dir}"
		cmake-utils_src_install

		einfo "Installing 64bit libs..."
	)

	# Install native version
	cmake-utils_src_install

	# Make config dir
	dodir /etc/VirtualGL
	fowners root:video /etc/VirtualGL
	fperms 0750 /etc/VirtualGL
	newinitd "${FILESDIR}/vgl.initd" vgl
	newconfd "${FILESDIR}/vgl.confd" vgl

	# Rename glxinfo to vglxinfo to avoid conflict with x11-apps/mesa-progs
	mv "${D}"/usr/bin/{,v}glxinfo
}

pkg_postinst() {
	ewarn "You might need to adjust /etc/conf.d/vgl for your setup!"
}
