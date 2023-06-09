# app custom Makefile


# Docker repo & image name without version
IMAGE    ?= docker.io/netboxcommunity/netbox

# Hostname for external access
APP_SITE ?= netbox.dev.lan
# App names (db/user name etc)
APP_NAME ?= netbox

# PgSQL used as DB
USE_DB = yes

# ------------------------------------------------------------------------------
# app custom config

IMAGE_VER            ?= latest

REDIS_IMAGE          ?= docker.io/redis
REDIS_IMAGE_VER      ?= 7-alpine

REDIS_PASSWORD       ?= $(shell < /dev/urandom tr -dc A-Za-z0-9 2>/dev/null | head -c14; echo)
REDIS_CACHE_PASSWORD ?= $(shell < /dev/urandom tr -dc A-Za-z0-9 2>/dev/null | head -c14; echo)
SECRET_KEY           ?= $(shell < /dev/urandom tr -dc A-Za-z0-9 2>/dev/null | head -c64; echo)

EMAIL_FROM           ?= netbox@bar.com
EMAIL_PASSWORD       ?=
EMAIL_PORT           ?= 25
EMAIL_SERVER         ?= localhost
EMAIL_USERNAME       ?= netbox

DCAPE_ROOT           ?= /opt/dcape/var

DATA_PATH            ?= $(APP_NAME)

# ------------------------------------------------------------------------------
# .env template (custom part)
# inserted in .env.sample via 'make config'
define CONFIG_CUSTOM
# ------------------------------------------------------------------------------
# app custom config, generated by make config
# db:$(USE_DB) user:$(ADD_USER)

REDIS_IMAGE=$(REDIS_IMAGE)
REDIS_IMAGE_VER=$(REDIS_IMAGE_VER)

REDIS_PASSWORD=$(REDIS_PASSWORD)
REDIS_CACHE_PASSWORD=$(REDIS_CACHE_PASSWORD)
SECRET_KEY=$(SECRET_KEY)

EMAIL_FROM=$(EMAIL_FROM)
EMAIL_PASSWORD=$(EMAIL_PASSWORD)
EMAIL_PORT=$(EMAIL_PORT)
EMAIL_SERVER=$(EMAIL_SERVER)
EMAIL_USERNAME=$(EMAIL_USERNAME)

# Path to /opt/dcape/var. Used only outside drone
DCAPE_ROOT=$(DCAPE_ROOT)

DATA_PATH=$(DATA_PATH)

endef

# ------------------------------------------------------------------------------
# Find and include DCAPE/apps/drone/dcape-app/Makefile
DCAPE_COMPOSE   ?= dcape-compose
DCAPE_MAKEFILE  ?= $(shell docker inspect -f "{{.Config.Labels.dcape_app_makefile}}" $(DCAPE_COMPOSE))
ifeq ($(shell test -e $(DCAPE_MAKEFILE) && echo -n yes),yes)
  include $(DCAPE_MAKEFILE)
else
  include /opt/dcape-app/Makefile
endif


## create superuser
admin-add: CMD=run app ./manage.py createsuperuser
admin-add: dc

