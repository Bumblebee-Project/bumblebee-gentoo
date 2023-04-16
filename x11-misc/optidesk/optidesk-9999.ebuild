# Copyright 1999-2023 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Tool to add .desktop files to be used by optirun"
HOMEPAGE="https://github.com/Bumblebee-Project/optidesk"

inherit autotools

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
