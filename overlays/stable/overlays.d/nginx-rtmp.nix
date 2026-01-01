# SPDX-FileCopyrightText: 2024-2026 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
#
_: prev: {
  nginx-rtmp = prev.nginxStable.override (oldAttrs: {
    pname = "nginx-rtmp";
    modules = oldAttrs.modules ++ [prev.nginxModules.rtmp];
  });
}
