# Copyright 1999-2023 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DESCRIPTION="Sil-Q Roguelike"
HOMEPAGE="https://github.com/sil-quirk/sil-q"
SRC_URI="https://github.com/sil-quirk/sil-q/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64"
SLOT="0"
IUSE=""

BDEPEND=""
DEPEND="x11-libs/libX11
        sys-libs/ncurses"
RDEPEND="${DEPEND}"

src_prepare() {
	# modify makefile to link against ncurses and tinfo (ncurses package)
	sed -i '0,/LIBS = -lX11 -lcurses/{s/-lcurses/-lncurses -ltinfo/}' src/Makefile.std
	eapply_user
}

src_compile() {
	cd src
	emake -f Makefile.std install
}

OPT_PATH="/opt/sil-q"

src_install() {
	# copy files to /opt/sil-q
	insinto ${OPT_PATH}
	doins sil
	doins silg
	doins silx
	doins -r lib
	# make binaries executable
	fperms 0755 ${OPT_PATH}/sil
	fperms 0755 ${OPT_PATH}/silg
	fperms 0755 ${OPT_PATH}/silx
	# make certain parts of the lib directory writeable by the users group
	fowners root:users ${OPT_PATH}/lib/data
	fowners root:users ${OPT_PATH}/lib/save
	fowners root:users ${OPT_PATH}/lib/user
	fperms g+w ${OPT_PATH}/lib/data
	fperms g+w ${OPT_PATH}/lib/save
	fperms g+w ${OPT_PATH}/lib/user

	# add a cd call in silx/silg so they are run from the install dir
	sed -i "s,# Launch SIL,# Launch SIL\ncd ${OPT_PATH}," "${D}${OPT_PATH}/silg"
	sed -i "s,# Launch SIL,# Launch SIL\ncd ${OPT_PATH}," "${D}${OPT_PATH}/silx"

	# make a script to launch sil from the opt directory
	SCRIPT="${D}${OPT_PATH}/sil.sh"
	echo "#!/bin/bash" > ${SCRIPT}
	echo "pushd ${OPT_PATH}" >> ${SCRIPT}
	echo "./sil &" >> ${SCRIPT}
	echo "popd" >> ${SCRIPT}
	fperms 0755 ${OPT_PATH}/sil.sh

	# create symlinks in /usr/bin
	dosym ${OPT_PATH}/sil.sh /usr/bin/sil
	dosym ${OPT_PATH}/silx /usr/bin/silx
	dosym ${OPT_PATH}/silg /usr/bin/silg
}
