prepare:
	@bash ./btool/prepare.sh
	@bash ./btool/gen_cc.sh
akb: prepare
	@bash ./btool/build_btool.sh
clean:
	rm -rf build/ out/ tmplib/ ./btool/akb_cc
installer: prepare
	@bash ./btool/build_btool_install.sh
deb: prepare
	@bash ./btool/build_btool_dpkg.sh
all: akb
	@bash ./btool/build_btool_install.sh
	@bash ./btool/build_btool_dpkg.sh

