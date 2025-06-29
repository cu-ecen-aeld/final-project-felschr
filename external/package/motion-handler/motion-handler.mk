##############################################################
#
# MOTION-HANDLER
#
##############################################################

MOTION_HANDLER_VERSION = '0.1'
MOTION_HANDLER_SITE = $(TOPDIR)/../../motion-handler
MOTION_HANDLER_SITE_METHOD = local

MOTION_HANDLER_CFLAGS = $(TARGET_CFLAGS)
MOTION_HANDLER_CFLAGS += -D_GNU_SOURCE

define MOTION_HANDLER_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) CFLAGS="$(MOTION_HANDLER_CFLAGS)" \
		$(MAKE) -C $(@D) all
endef

define MOTION_HANDLER_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 $(@D)/motion-handler $(TARGET_DIR)/usr/bin
	$(INSTALL) -m 0755 $(@D)/motion-handler-start-stop $(TARGET_DIR)/etc/init.d/S99motion-handler
endef

$(eval $(generic-package))
