EAPI=8

inherit git-r3
EGIT_REPO_URI="https://github.com/jimf256/GentooAutoUpdate.git"

DESCRIPTION="Auto-update boot option for portage"
HOMEPAGE="https://github.com/jimf256/GentooAutoUpdate"
LICENSE="GPL-2"
KEYWORDS="~amd64"
SLOT="0"
IUSE=""

BDEPEND=""
DEPEND=""
RDEPEND=""

src_unpack() {
	default

	# grab the latest git repo contents
	git-r3_src_unpack

	# the following is in src_unpack to get around network sandbox in other phases
	# create python virtual env
	python -m venv ${S}/env
	# install discord.py via pip
	${S}/env/bin/pip install discord.py
}

src_install() {
	# install main python file and python environment
	exeinto /opt/${PN}
	doexe auto-update.py
	insinto /opt/${PN}
	doins -r env
	# install post-kernel-install hook
	exeinto /etc/kernel/postinst.d
	doexe 90-update-grub-custom-option
	# install config file to /etc
	insinto /etc
	doins auto-update.conf
	fperms 0400 /etc/auto-update.conf
	# install grub config file with custom boot option
	exeinto /etc/grub.d
	doexe 40_custom_auto-update
	# install openrc init script
	newinitd init_script.sh auto-update
}

pkg_preinst() {
	# update the 40_custom grub config to have the correct (current) kernel version
	old_ver="$(cat ${D}/etc/grub.d/40_custom_auto-update | grep vmlinuz | sed 's/.*vmlinuz-\(.*\) root.*/\1/')"
	new_ver="$(uname -r)"
	sed -i "s/$old_ver/$new_ver/" ${D}/etc/grub.d/40_custom_auto-update
}

pkg_postinst() {
	# update grub config
	grub-mkconfig -o /boot/grub/grub.cfg
	# add auto-update service to default runlevel
	rc-update add auto-update
}

pkg_prerm() {
	# remove log files
	rm S{ROOT}/opt/${PN}/*.txt
	# remove service from default runlevel
	rc-update del auto-update
}

pkg_postrm() {
	# update grub config
	grub-mkconfig -o /boot/grub/grub.cfg
}
