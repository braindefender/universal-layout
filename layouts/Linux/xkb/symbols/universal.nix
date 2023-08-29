{pkgs, ...}: {
  services.xserver = {
    layout = "universal";

    extraLayouts = {
      universal = {
        description = "Universal Layout";
        languages = ["eng"];
        symbolsFile = ./universal;
      };
    };
  };
}
