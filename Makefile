include $(THEOS)/makefiles/common.mk

ARCHS = armv7 armv7s arm64
TWEAK_NAME = PassConnect
PassConnect_FILES = Tweak.xm

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 AnyConnect"
