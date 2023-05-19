# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8
inherit linux-mod


# create a release from a hardcoded commit, PV is the commit date (YYYY.MM.DD)
GIT_COMMIT="a133274b0532c17318e8790b771566f4a6b12b7c"

SRC_URI="https://github.com/morrownr/8821au-20210708/archive/${GIT_COMMIT}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/8821au-20210708-${GIT_COMMIT}"

DESCRIPTION="Driver for Realtek 8821au USB Wifi Dongle"
HOMEPAGE="https://github.com/morrownr/8821au-20210708.git"
LICENSE="GPL-2"
KEYWORDS="~amd64"
SLOT="0"
IUSE=""

BDEPEND=""
DEPEND=""
RDEPEND=""

MODULE_NAMES="8821au(kernel/net/wireless:${S}:${S})"
BUILD_TARGETS="clean modules"

PATCHES=(
	"${FILESDIR}/${PN}-kernel-src-dir.patch"
)

pkg_setup() {
	linux-mod_pkg_setup
	# cache the net interface name (assumes only one is set up, ignoring loopback)
	export INTERFACE="$(rc-service -l | grep -i 'net\.' | grep -iv 'net.lo')"
}
src_configure() {
	set_arch_to_kernel
	default
}

src_compile() {
	linux-mod_src_compile
}

src_install() {
	linux-mod_src_install
	insinto /etc/modprobe.d
	doins 8821au.conf
}

pkg_postinst() {
	linux-mod_pkg_postinst

	# load the module and restart the network service
	modprobe 8821au
	rc-service ${INTERFACE} restart
}

pkg_postrm() {
	linux-mod_pkg_postrm
	# note: the module doesn't actually get removed or unloaded
	#       causes too many issues during a re-install
}
