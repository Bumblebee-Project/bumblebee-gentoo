# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=6
inherit autotools git-r3 multilib eutils readme.gentoo-r1 systemd user

DESCRIPTION="Service providing elegant and stable means of managing Optimus graphics chipsets"
HOMEPAGE="http://bumblebee-project.org https://github.com/Bumblebee-Project/Bumblebee"
EGIT_REPO_URI="https://github.com/Bumblebee-Project/${PN^}.git"
EGIT_BRANCH="develop"
SRC_URI=""

SLOT="0"
LICENSE="GPL-3"
KEYWORDS=""

IUSE="+bbswitch video_cards_nouveau video_cards_nvidia"

RDEPEND="
	virtual/opengl
	x11-base/xorg-drivers[video_cards_nvidia?,video_cards_nouveau?]
	bbswitch? ( sys-power/bbswitch:= )
"
DEPEND="${RDEPEND}
	dev-libs/glib:2
	dev-libs/libbsd
	sys-apps/help2man
	virtual/pkgconfig
	x11-libs/libX11
"

PDEPEND="
	|| (
		x11-misc/primus:=
		x11-misc/virtualgl:=
	)
"

REQUIRED_USE="|| ( video_cards_nouveau video_cards_nvidia )"

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	DOC_CONTENTS="In order to use Bumblebee, add your user to 'bumblebee' group.
		You may need to setup your /etc/bumblebee/bumblebee.conf"

	if use video_cards_nvidia ; then
		# use ABI-independent path ($LIB is interpreted by ld.so, $$
		# escapes $ for make
		nvlib='/usr/$$LIB/opengl/nvidia/lib'

		local nvpref="/usr/$(get_libdir)/opengl/nvidia"
		local xorgpref="/usr/$(get_libdir)/xorg/modules"
		local myeconfargs=()
		myeconfargs+=(
			"CONF_DRIVER=nvidia"
			"CONF_DRIVER_MODULE_NVIDIA=nvidia"
			"CONF_LDPATH_NVIDIA=${nvlib#:}"
			"CONF_MODPATH_NVIDIA=${nvpref}/lib,${nvpref}/extensions,${xorgpref}/drivers,${xorgpref}"
		)
	fi

	econf \
		--docdir=/usr/share/doc/"${PF}" \
		${myeconfargs[@]}
}

src_compile() {
	emake scripts/systemd/bumblebeed.service
	default
}

src_install() {
	newconfd "${FILESDIR}"/bumblebee.confd bumblebee
	newinitd "${FILESDIR}"/bumblebee.initd bumblebee
	newenvd  "${FILESDIR}"/bumblebee.envd 99bumblebee
	systemd_dounit scripts/systemd/bumblebeed.service

	readme.gentoo_create_doc

	default
}

pkg_preinst() {
	use video_cards_nvidia || rm "${ED}"/etc/bumblebee/xorg.conf.nvidia
	use video_cards_nouveau || rm "${ED}"/etc/bumblebee/xorg.conf.nouveau

	enewgroup bumblebee
}

pkg_postinst() {
	readme.gentoo_print_elog
}
