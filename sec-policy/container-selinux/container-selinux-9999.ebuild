# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="6"

inherit eutils

DESCRIPTION="SELinux policy for container-selinux"
HOMEPAGE="https://github.com/containers/container-selinux"
LICENSE="GPL-2"
SLOT="0"

if [[ ${PV} == 9999* ]]; then
	EGIT_REPO_URI="https://github.com/containers/container-selinux.git"
	EGIT_BRANCH="master"
	EGIT_CHECKOUT_DIR="${WORKDIR}/refpolicy"
	inherit git-r3
else
	SRC_URI="https://github.com/containers/container-selinux/archive/v${PV}.tar.gz"
	KEYWORDS="amd64 arm64"
fi

IUSE=""

DEPEND="<sec-policy/selinux-base-9999"

src_prepare() {
	local config="${EROOT}"/usr/lib/selinux/config

	SELINUX_TYPE=$(awk -F'=' '/SELINUXTYPE=/ {print $2}' ${config} 2>/dev/null)
	[ -n "${SELINUX_TYPE}" ] || die "Can't determine SELINUXTYPE from ${config}"

	SELINUX_MAKEFILE="${EROOT}"/usr/share/selinux/${SELINUX_TYPE}/include/Makefile
	[ -f  ${SELINUX_MAKEFILE} ] || die "Can't find ${SELINUX_MAKEFILE}"

	POLICY_TYPES="mcs mls targeted"

	epatch "${FILESDIR}"/0001-2.132.0-fix-container-selinux-flatcar.patch
	eapply_user
}

src_compile() {
	emake NAME=${SELINUX_TYPE} SHAREDIR="${EROOT}"/usr/share/selinux \
		-f "${SELINUX_MAKEFILE}" container.pp \
		|| die "compile failed"
}

src_install() {
	for type in ${POLICY_TYPES}; do
		insinto /usr/share/selinux/${type}
		if [[ -f "${S}"/container.pp ]]; then
			doins "${S}"/container.pp || die "Failed to add container.pp to /usr/share/selinux/${type}"
		fi
	done
}
