TARGET := iphone:clang:latest:14.0
ARCHS := arm64

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = StarTok

StarTok_FILES = TTRoot.xm StarTokManager.m StarBadges.xm StarChat.xm StarGuard.xm NomadMode.xm MediaDownloader.xm UIEnhancements.xm StarSettings.xm
StarTok_CFLAGS = -fobjc-arc -Wno-unused-variable -Wno-unused-function -Wno-deprecated-declarations
StarTok_FRAMEWORKS = UIKit Foundation CoreTelephony CoreMotion AudioToolbox AVFoundation AVKit Photos

include $(THEOS_MAKE_PATH)/tweak.mk
