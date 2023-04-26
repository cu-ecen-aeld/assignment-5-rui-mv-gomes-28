
##############################################################
#
# LDD
#
##############################################################

LDD_VERSION = 48f6857c0c32e1674e2f24747aa14803d7f0f9e7
# Note: Be sure to reference the *ssh* repository URL here (not https) to work properly
# with ssh keys and the automated build/test system.
# Your site should start with git@github.com:
LDD_SITE = git@github.com:cu-ecen-aeld/assignment-7-jaredcreech.git
LDD_SITE_METHOD = git
LDD_GIT_SUBMODULES = YES

LDD_MODULE_SUBDIRS = misc-modules scull
LDD_MODULE_MAKE_OPTS = KERNELRELEASE=$(LINUX_VERSION_PROBED)

$(eval $(kernel-module))
$(eval $(generic-package))
