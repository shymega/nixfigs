name: "Flakes workflow"

on:
  push:
  schedule:
    - cron: '0 0 * * 1'


jobs:
  update-flakes
    permissions:
      pull_requests: write
      contents: write
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: cachix/install-nix-action@v19
        with:
          github_access_token: ${{ secrets.GITHUB_TOKEN }}
      - name: Update flake.lock
        id: flake-update
        uses: DeterminateSystems/update-flake-lock@vX
        with:
          pr-title: "[Auto]: Update flake.lock"
          pr-labels: |
            dependencies
            automated
      - name: Automatically merge PR.
        uses: peter-evans/enable-pull-request-automerge@v3
        with:
          token: ${{ secrets.GITHUB_TOKEN }}
          pull-request-number: ${{ steps.flake-update.outputs.pull-request-number }}

  test-flakes:  
    needs:
      - update-flakes
    steps:
    - name: Checkout nixfigs.
      uses: actions/checkout@v3
    - name: Install Nix.
      uses: cachix/install-nix-action@v19
      with:
        github_access_token: ${{ secrets.GITHUB_TOKEN }}
    - name: "Build Flake.
      run: nix build
    - name: "Check flake.
      run: nix flake check