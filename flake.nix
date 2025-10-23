{
  description = "Development shell for the Page Builder project";
  
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
  
  outputs = { nixpkgs, ... }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {    
    devShells.${system}.default = pkgs.mkShell {
      buildInputs = with pkgs; [ 
        beamMinimal27Packages.erlang
        beamMinimal27Packages.elixir
          beamMinimal27Packages.elixir-ls

        nodejs
      ];

      env = {
        POSTGRES_USER = "postgres";
        POSTGRES_PASSWORD = "postgres";
        POSTGRES_HOST = "localhost";
        POSTGRES_DB = "page_builder_dev";
      };

      shellHook = ''
        echo "############################################"
        echo "############################################"
        echo "###                                      ###"
        echo "###    Page Builder development shell    ###"
        echo "###                                      ###"
        echo "############################################"
        echo "############################################"
      '';
    };
  };
}
