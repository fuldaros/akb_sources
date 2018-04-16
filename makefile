akb:
	@bash ./btool/build_btool.sh
clean:
	rm -rf build/ out/
installer:
	bash ./btool/build_btool_install.sh
