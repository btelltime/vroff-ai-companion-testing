{
  description = "Vroff AI Companion testing-release environment";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          baseTools = with pkgs; [ bash coreutils gh git jq nodejs ripgrep ];
          targetTools = {
            linux-deb = with pkgs; [ dpkg fakeroot ];
            linux-rpm = with pkgs; [ rpm gnused ];
            linux-appimage = [ ];
            linux-zip = [ ];
            macos-x64 = [ ];
            macos-arm64 = [ ];
            windows-x64 = with pkgs; [ mono wineWow64Packages.stableFull ];
          };
          mkReleaseShell = tools: pkgs.mkShell { packages = baseTools ++ tools; };
          targetShells = builtins.mapAttrs (_: tools: mkReleaseShell tools) targetTools;
        in targetShells // {
          default = mkReleaseShell (pkgs.lib.concatLists (builtins.attrValues targetTools));
          release = mkReleaseShell (pkgs.lib.concatLists (builtins.attrValues targetTools));
        });

      apps = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
          release = pkgs.writeShellApplication {
            name = "release";
            runtimeInputs = with pkgs; [ bash coreutils git nix ];
            text = ''
              release_root=$(git rev-parse --show-toplevel)
              target_count=0
              target=

              for argument in "$@"; do
                case "$argument" in
                  --help|-h) exec "$release_root/release-companion" "$@" ;;
                  linux-deb|linux-rpm|linux-appimage|linux-zip|macos-x64|macos-arm64|windows-x64)
                    target="$argument"
                    target_count=$((target_count + 1))
                    ;;
                esac
              done

              if [ "$target_count" -eq 1 ]; then
                exec nix develop "$release_root#$target" --command "$release_root/release-companion" "$@"
              fi

              if [ "$target_count" -eq 0 ]; then
                exec nix develop "$release_root#release" --command "$release_root/release-companion" --interactive "$@"
              fi

              exec nix develop "$release_root#release" --command "$release_root/release-companion" "$@"
            '';
          };
        in {
          default = { type = "app"; program = "${release}/bin/release"; };
          release = { type = "app"; program = "${release}/bin/release"; };
        });
    };
}
