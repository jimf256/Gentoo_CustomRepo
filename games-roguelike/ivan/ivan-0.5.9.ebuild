EAPI=8

MY_PV="$(ver_rs 1- '')"
S="${WORKDIR}/ivan-${MY_PV}"

DESCRIPTION="IVAN Roguelike"
HOMEPAGE="https://github.com/Attnam/ivan"
SRC_URI="https://github.com/Attnam/ivan/archive/refs/tags/v${MY_PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2"
KEYWORDS="~amd64"
SLOT="0"
IUSE=""

BDEPEND="dev-build/cmake"
DEPEND="media-libs/libsdl2
        media-libs/sdl2-mixer
        media-libs/libpng
        dev-libs/libpcre"

RDEPEND="${DEPEND}"

src_configure() {
	mkdir build
	cd build
	cmake -DCMAKE_INSTALL_PREFIX=/usr/ ../
}

src_compile() {
	cd build
	emake
}

src_install() {
	cd build
	emake DESTDIR="${D}" install
}
