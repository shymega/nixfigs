# SPDX-FileCopyrightText: 2023-2026 Dom 'shymega' Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: Apache-2.0
#
_: prev: {
  nginx-rtmp = prev.nginxStable.override (oldAttrs: {
    pname = "nginx-rtmp";
    modules = oldAttrs.modules ++ [prev.nginxModules.rtmp];
  });
}
