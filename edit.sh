#!/bin/sh

git filter-repo --commit-callback "
  if b'Update Flake lockfile' in commit.message:
    commit.author_email = b'41898282+github-actions[bot]@users.noreply.github.com'
    commit.author_name = b'github-actions[bot]'
    commit.committer_email = b'41898282+github-actions[bot]@users.noreply.github.com'
    commit.committer_name = b'github-actions[bot]'

  if b'Format Nix files' in commit.message:
    commit.author_email = b'41898282+github-actions[bot]@users.noreply.github.com'
    commit.author_name = b'github-actions[bot]'
    commit.committer_email = b'41898282+github-actions[bot]@users.noreply.github.com'
    commit.committer_name = b'github-actions[bot]'
" --force
