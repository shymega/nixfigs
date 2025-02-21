# SPDX-FileCopyrightText: 2023 Dom Rodriguez <shymega@shymega.org.uk>
#
# SPDX-License-Identifier: GPL-3.0-only

{ python3Packages
, fetchPypi
}:
python3Packages.buildPythonApplication rec {
  pname = "totp-cli";
  version = "1.3.0";
  pyproject = true;

  src = fetchPypi {
    pname = "totp";
    inherit version;
    hash = "";
  };

  build-system = with python3Packages; [
    setuptools
  ];
}
