{pkgs, ...}: {
  services.xserver = {
    layout = "universal_ortho";

    extraLayouts = {
      universal = {
        description = "Universal Layout Ortho";
        languages = ["eng"];
        symbolsFile = ./universal_ortho;
      };
    };
  };
}
