# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=5
inherit cmake-multilib multilib systemd subversion

DESCRIPTION="Run OpenGL applications remotely with full 3D hardware acceleration"
HOMEPAGE="http://www.virtualgl.org/"
ESVN_REPO_URI="https://virtualgl.svn.sourceforge.net/svnroot/virtualgl/vgl/trunk"
SRC_URI=""

SLOT="0"
LICENSE="LGPL-2.1 wxWinLL-3.1 FLTK"
KEYWORDS=""
IUSE="ssl"

RDEPEND="
	ssl? ( dev-libs/openssl )
	media-libs/libjpeg-turbo
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXv
	amd64? ( abi_x86_32? (
		|| (
			(
				x11-libs/libX11[abi_x86_32]
				x11-libs/libXext[abi_x86_32]
				x11-libs/libXv[abi_x86_32]
			)
			app-emulation/emul-linux-x86-xlibs
		)
		app-emulation/emul-linux-x86-baselibs
		app-emulation/emul-linux-x86-opengl
	) )
	virtual/glu
	virtual/opengl
"
DEPEND="${RDEPEND}"

src_prepare() {
	# Use /var/lib, bug #428122
	sed -e "s#/etc/opt#/var/lib#g" -i doc/unixconfig.txt doc/index.html doc/advancedopengl.txt \
		server/vglrun server/vglgenkey server/vglserver_config || die

	default
}

src_configure() {
	abi_configure() {
		local mycmakeargs=(
			$(cmake-utils_use ssl VGL_USESSL)
			-DVGL_DOCDIR=/usr/share/doc/"${P}"
			-DTJPEG_INCLUDE_DIR=/usr/include
			-DVGL_LIBDIR=/usr/$(get_libdir)
			-DTJPEG_LIBRARY=/usr/$(get_libdir)/libturbojpeg.so
			-DCMAKE_LIBRARY_PATH=/usr/$(get_libdir)
			-DVGL_FAKELIBDIR=/usr/$(get_libdir)/vgl-fakelib
		)
		cmake-utils_src_configure
	}
	multilib_parallel_foreach_abi abi_configure
}

src_install() {
	cmake-multilib_src_install

	# Make config dir
	dodir /var/lib/VirtualGL
	fowners root:video /var/lib/VirtualGL
	fperms 0750 /var/lib/VirtualGL
	newinitd "${FILESDIR}/vgl.initd" vgl
	newconfd "${FILESDIR}/vgl.confd" vgl

	exeinto /usr/libexec
	doexe "${FILESDIR}/vgl-helper.sh"
	systemd_dounit "${FILESDIR}/vgl.service"

	# Rename glxinfo to vglxinfo to avoid conflict with x11-apps/mesa-progs
	mv "${D}"/usr/bin/{,v}glxinfo || die
}
