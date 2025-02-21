{ lib
, buildGoModule
, fetchFromGitHub
, olm
,
}:
buildGoModule {
  pname = "mautrix-slack";
  version = "2024-08-16";

  src = fetchFromGitHub {
    owner = "mautrix";
    repo = "slack";
    rev = "7ff1bec72a4ad989f8415d75a13d7b5694e12bca";
    hash = "sha256-Ro4KRsagztvQSzZZJEqe0UY80JrFiZO2TqCsOzeZpYc=";
  };

  buildInputs = [
    olm
  ];

  vendorHash = "sha256-VU3Q2PDdRHUnXTyKmBe7qNKYMX6Lf4+eHoBxXWH8Qaw=";

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/mautrix/slack";
    description = "A Matrix-Slack puppeting bridge";
    license = licenses.agpl3Plus;
    maintainers = with maintainers; [ kittywitch ];
    mainProgram = "mautrix-slack";
  };
}
