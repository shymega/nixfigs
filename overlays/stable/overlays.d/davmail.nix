# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only
_: prev: {
  davmail = prev.davmail.overrideAttrs (oldAttrs: rec {
    inherit (oldAttrs) pname;
    version = "6.3.0";
    rev = 3627;

    src = prev.fetchurl {
      url = "mirror://sourceforge/${pname}/${version}/${pname}-${version}-${toString rev}.zip";
      hash = "sha256-Yh61ZHsEMF6SchLEyBV3rRI7pJ/bvR2K4G8U6jrPa3A=";
    };
  });
}
