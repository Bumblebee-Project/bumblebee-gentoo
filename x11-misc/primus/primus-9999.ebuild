# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit multilib-build git-r3

DESCRIPTION="Faster OpenGL offloading for Bumblebee"
HOMEPAGE="https://github.com/amonakov/primus"
EGIT_REPO_URI="https://github.com/amonakov/primus.git"

LICENSE="ISC"
SLOT="0"

RDEPEND="
	x11-misc/bumblebee[video_cards_nvidia]
	x11-drivers/nvidia-drivers
"
DEPEND="virtual/opengl"

# TODO: XXX: REWRITE ALL OF THIS, NVIDIA IS NO MORE non-GLVND
# ref: https://github.com/amonakov/primus/issues/206

src_compile() {
	export PRIMUS_libGLa='/usr/$$LIB/opengl/nvidia/lib/libGL.so.1'
	mymake() {
		emake LIBDIR=$(get_libdir)
	}
	multilib_foreach_abi mymake
}

src_install() {
	sed -i -e "s#^PRIMUS_libGL=.*#PRIMUS_libGL='/usr/\$LIB/primus'#" primusrun
	dobin primusrun
	myinst() {
		insinto /usr/$(get_libdir)/primus
		doins "${S}"/$(get_libdir)/libGL.so.1
	}
	multilib_foreach_abi myinst
}
