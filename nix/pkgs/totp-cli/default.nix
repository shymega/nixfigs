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
    hash = "sha256-reWv3pH1NaO7wKAt4kbfrewKS6RlpZFH4NsYb2ai43I=";
  };

  build-system = with python3Packages; [
    setuptools
    setuptools_scm
  ];

  dependencies = with python3Packages; [
    onetimepass
  ];
}
