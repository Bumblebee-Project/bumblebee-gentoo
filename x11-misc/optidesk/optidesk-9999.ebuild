# Copyright 1999-2020 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=7

DESCRIPTION="Optidesk"
HOMEPAGE="https://github.com/Bumblebee-Project/optidesk"

inherit autotools eutils

if [[ ${PV} =~ "9999" ]]; then
	inherit git-r3
	EGIT_REPO_URI="https://github.com/Bumblebee-Project/${PN}.git"
else
	SRC_URI="https://github.com/downloads/Bumblebee-Project/${PN}/${P}.tar.gz"
	KEYWORDS="~amd64 ~x86"
fi

SLOT="0"
LICENSE="GPL-3"

RDEPEND="dev-libs/glib:2"
DEPEND="
	${RDEPEND}
	>=sys-devel/autoconf-2.68
	sys-devel/automake
	sys-devel/gcc
"

src_prepare() {
	default
	eautoreconf
}
