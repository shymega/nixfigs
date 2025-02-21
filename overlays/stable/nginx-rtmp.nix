# SPDX-FileCopyrightText: 2024 Dom Rodriguez <shymega@shymega.org.uk
#
# SPDX-License-Identifier: GPL-3.0-only

#

_final: prev: {
  nginx-rtmp-patched = prev.nginxStable.override (oldAttrs: {
    pname = "nginx-rtmp-patched";
    version = "stable";
    modules = oldAttrs.modules ++ [ prev.nginxModules.rtmp ];
  });
}
