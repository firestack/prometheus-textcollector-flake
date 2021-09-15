{ config, lib, pkgs, ... }: let cfg = config.services.smartmonpy; in {

	options.services.smartmonpy = {
		enable = lib.mkEnableOption "Enable Smartmon.py";

		extraOptions = lib.mkOption {
			description = "Extra arguments passed to smartmonpy";
			type = lib.types.str;
		};
		
		outFile = lib.mkOption {
			description = "Which filepath the metrics output should be written";
			type = lib.types.path;
		};

	};

	config = lib.mkIf cfg.enable {
	systemd.services.smartmonpy = {
		description = "S.M.A.R.T.(smartmon py) prometheus collector";
		wantedBy = [ "multi-user.target" ];
		serviceConfig.ExecStart = "${cfg.program} ${lib.concatStringsSep " " cfg.extraOptions} > ${cfg.outFile}";
	};};
}