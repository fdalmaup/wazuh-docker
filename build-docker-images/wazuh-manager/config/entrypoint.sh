#!/bin/bash
if [ "$2" == "vscode" ]; then
	/var/ossec/framework/python/bin/pip3 install ptvsd
else
	/var/ossec/framework/python/bin/pip3 install pydevd-pycharm
fi

ln -sf $(grep USER_DIR /wazuh/etc/preloaded-vars.conf |  sed -E 's/USER_DIR|\"|=//g')/framework/python/bin/python3 /usr/local/bin/wpy

/bin/supervisord -c /etc/supervisor/conf.d/supervisord.conf