# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

if [[ ${PV} =~ "9999" ]]; then
	SCM_ECLASS="git-2"
	EGIT_REPO_URI="https://github.com/Bumblebee-Project/${PN/bu/Bu}.git"
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="https://github.com/downloads/Bumblebee-Project/${PN/bu/Bu}/${P/bu/Bu}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

inherit autotools eutils multilib ${SCM_ECLASS}

DESCRIPTION="Service providing elegant and stable means of managing Optimus graphics chipsets"
HOMEPAGE="https://github.com/Bumblebee-Project/Bumblebee"

SLOT="0"
LICENSE="GPL-3"

IUSE="+powersave video_cards_nouveau video_cards_nvidia"

RDEPEND="x11-misc/virtualgl
	powersave? ( sys-drivers/bbswitch )
	virtual/opengl
	x11-base/xorg-drivers[video_cards_nvidia?,video_cards_nouveau?]"
DEPEND=">=sys-devel/autoconf-2.68
	sys-devel/automake
	sys-devel/gcc
	dev-util/pkgconfig
	dev-libs/glib:2
	x11-libs/libX11
	dev-libs/libbsd
	sys-apps/help2man"

src_prepare() {
	epatch_user
	if [[ ${PV} =~ "9999" ]]; then
		eautoreconf
	fi
}

src_configure() {
	use video_cards_nvidia || use video_cards_nouveau \
		|| die "You should enable at least one of supported VIDEO_CARDS!"

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
	use video_cards_nvidia && newconfd "${FILESDIR}"/bumblebee.nvidia-confd bumblebee
	use video_cards_nouveau && newconfd "${FILESDIR}"/bumblebee.nouveau-confd bumblebee
	newinitd "${FILESDIR}"/bumblebee.initd bumblebee
	default
}

pkg_preinst() {
	! use video_cards_nvidia && rm "${D}"/etc/bumblebee/xorg.conf.nvidia
	! use video_cards_nouveau && rm "${D}"/etc/bumblebee/xorg.conf.nouveau

	enewgroup bumblebee
}

pkg_postinst() {
	ewarn "This is *NOT* all! Bumblebee still *NOT* ready to use."
	ewarn "You may need to setup your /etc/bumblebee/bumblebee.conf!"
	ewarn "For example, default config suggests you have bbswitch installed."
	ewarn "Also you should add your user to 'bumblebee' group."
}
