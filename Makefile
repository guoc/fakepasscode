export ARCHS=armv7 arm64
include $(THEOS)/makefiles/common.mk

TWEAK_NAME = fakepasscode
fakepasscode_FILES = Tweak.xm
fakepasscode_LDFLAGS = -lactivator

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
SUBPROJECTS += fakepasscodesettings
include $(THEOS_MAKE_PATH)/aggregate.mk
