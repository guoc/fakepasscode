include theos/makefiles/common.mk

BUNDLE_NAME = FakePasscodeSettings
FakePasscodeSettings_FILES = FakePasscodeSettings.mm
FakePasscodeSettings_INSTALL_PATH = /Library/PreferenceBundles
FakePasscodeSettings_FRAMEWORKS = UIKit
FakePasscodeSettings_PRIVATE_FRAMEWORKS = Preferences

include $(THEOS_MAKE_PATH)/bundle.mk

internal-stage::
	$(ECHO_NOTHING)mkdir -p $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences$(ECHO_END)
	$(ECHO_NOTHING)cp entry.plist $(THEOS_STAGING_DIR)/Library/PreferenceLoader/Preferences/FakePasscodeSettings.plist$(ECHO_END)
