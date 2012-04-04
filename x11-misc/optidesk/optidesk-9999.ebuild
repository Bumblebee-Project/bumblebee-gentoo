# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

DESCRIPTION=""
HOMEPAGE="https://github.com/Bumblebee-Project/optidesk"

if [[ ${PV} =~ "9999" ]]; then
	SCM_ECLASS="git-2"
	EGIT_REPO_URI="https://github.com/Bumblebee-Project/${PN}.git"
	SRC_URI=""
	KEYWORDS=""
else
	SRC_URI="https://github.com/downloads/Bumblebee-Project/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi;

inherit autotools eutils ${SCM_ECLASS}

SLOT="0"
LICENSE="GPL-3"

IUSE=""

RDEPEND="dev-libs/glib:2"
DEPEND="${RDEPEND}
	>=sys-devel/autoconf-2.68
	sys-devel/automake
	sys-devel/gcc"

src_prepare() {
	epatch_user
	eautoreconf
}
