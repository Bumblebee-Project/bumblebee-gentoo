# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit autotools base git-2 multilib

DESCRIPTION="Service providing elegant and stable means of managing Optimus graphics chipsets"
HOMEPAGE="https://github.com/Bumblebee-Project/Bumblebee"
EGIT_REPO_URI="https://github.com/Bumblebee-Project/${PN/bu/Bu}.git"
SRC_URI=""

SLOT="0"
LICENSE="GPL-3"
KEYWORDS=""

IUSE="+bbswitch video_cards_nouveau video_cards_nvidia"

RDEPEND="x11-misc/virtualgl
	bbswitch? ( sys-power/bbswitch )
	virtual/opengl
	x11-base/xorg-drivers[video_cards_nvidia?,video_cards_nouveau?]"
DEPEND=">=sys-devel/autoconf-2.68
	sys-devel/automake
	sys-devel/gcc
	virtual/pkgconfig
	dev-libs/glib:2
	x11-libs/libX11
	dev-libs/libbsd
	sys-apps/help2man"

REQUIRED_USE="|| ( video_cards_nouveau video_cards_nvidia )"

src_prepare() {
	base_src_prepare
	eautoreconf
}

src_configure() {
	if use video_cards_nvidia ; then
		# Get paths to GL libs for all ABIs
		local nvlib=""
		for i in  $(get_all_libdirs) ; do
			nvlib="${nvlib}:/usr/${i}/opengl/nvidia/lib"
		done

		local nvpref="/usr/$(get_libdir)/opengl/nvidia"
		local xorgpref="/usr/$(get_libdir)/xorg/modules"
		ECONF_PARAMS="CONF_DRIVER=nvidia CONF_DRIVER_MODULE_NVIDIA=nvidia \
			CONF_LDPATH_NVIDIA=${nvlib#:} \
			CONF_MODPATH_NVIDIA=${nvpref}/lib,${nvpref}/extensions,${xorgpref}/drivers,${xorgpref}"
	fi

	econf ${ECONF_PARAMS}
}

src_install() {
	newconfd "${FILESDIR}"/bumblebee.confd bumblebee
	newinitd "${FILESDIR}"/bumblebee.initd bumblebee
	newenvd  "${FILESDIR}"/bumblebee.envd 99bumblebee
	default
}

pkg_preinst() {
	! use video_cards_nvidia && rm "${D}"/etc/bumblebee/xorg.conf.nvidia
	! use video_cards_nouveau && rm "${D}"/etc/bumblebee/xorg.conf.nouveau

	enewgroup bumblebee
}

pkg_postinst() {
	ewarn "In order to use Bumblebee, add your user to 'bumblebee' group."
	ewarn "You may need to setup your /etc/bumblebee/bumblebee.conf!"
	ewarn "For example, default config suggests you have bbswitch installed."
}
