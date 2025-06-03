# SPDX-FileCopyrightText: 2025 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
_final: prev: {
  nginx-rtmp = prev.nginxStable.override (oldAttrs: {
    pname = "nginx-rtmp";
    modules = oldAttrs.modules ++ [prev.nginxModules.rtmp];
  });
}
