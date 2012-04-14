# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

if [[ ${PV} =~ "9999" ]]; then
	SCM_ECLASS="subversion"
	ESVN_REPO_URI="https://virtualgl.svn.sourceforge.net/svnroot/virtualgl/vgl/trunk"
	SRC_URI=""
	KEYWORDS=""
else
	MY_PN="VirtualGL"
	MY_P="${MY_PN}-${PV}"
	S="${WORKDIR}/${MY_P}"
	SRC_URI="mirror://sourceforge/${PN}/${MY_PN}/${PV}/${MY_P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

inherit cmake-utils ${SCM_ECLASS}

DESCRIPTION="Run OpenGL applications remotely with full 3D hardware acceleration"
HOMEPAGE="http://www.virtualgl.org/"

SLOT="0"
LICENSE="LGPL-2.1 wxWinLL-3.1 FLTK"
IUSE="ssl"

RDEPEND="ssl? ( dev-libs/openssl )
	media-libs/libjpeg-turbo
	x11-libs/libX11
	x11-libs/libXext
	x11-libs/libXv
	multilib? ( app-emulation/emul-linux-x86-xlibs app-emulation/emul-linux-x86-baselibs )
	virtual/opengl"

DEPEND="dev-util/cmake
	${RDEPEND}"

src_prepare() {
	for file in rr/vglgenkey rr/vglrun rr/vglserver_config doc/index.html; do
		sed -e "s#/etc/opt#/etc#g" -i ${file}
	done

	default
}

mlib_configure() {
	einfo "Multilib build enabled!"
	einfo "Building 32bit libs..."

	ml_builddir="${WORKDIR}/build32"
	mkdir "${ml_builddir}"
	pushd "${ml_builddir}" >/dev/null

	local CFLAGS="-m32 -O2 -march=native -pipe"
	local CXXFLAGS="${CFLAGS}"
	local LDFLAGS="-m32"
	local CMAKE_BUILD_DIR="${ml_builddir}"

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

	# Make it also here to be sure we are using this config
	emake

	popd >/dev/null
	einfo "Building 64bit libs..."
}

src_configure() {
	# Configure and make 32bit version on multilib
	use amd64 && use multilib && ABI=x86 mlib_configure

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

src_install() {
	# Install 32bit version on multilib
	use amd64 && use multilib && (
		pushd "${ml_builddir}" >/dev/null
		emake DESTDIR="${D}" install || die "Failed to install 32bit libs!"
		popd >/dev/null
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
