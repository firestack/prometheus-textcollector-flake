{ config, lib, pkgs, ... }: let cfg = config.services.nvme-metrics; in {

	options.services.nvme-metrics = {
		enable = lib.mkEnableOption "Enable Nvme-metrics.py";

		package = lib.mkOption {
			description = "which program path to point to";
			default = pkgs.nvme-metrics;
			type = lib.types.package;
		};
		program = lib.mkOption {
			type = lib.types.path;
			default = "${cfg.package.mainProgram}";
		};
		extraOptions = lib.mkOption {
			description = "Extra arguments passed to nvme-metrics";
			default = [];
			type = with lib.types; listOf str;
		};

		outFile = lib.mkOption {
			description = "Which filepath the metrics output should be written";
			default = "/var/lib/smartd-exporter/nvme-metrics.prom";
			type = lib.types.path;
		};

	};

	config = lib.mkIf cfg.enable {
	systemd.services.nvme-metrics = let 
	wrapper = pkgs.writeShellScript "nvme-metrics" ''
	${cfg.package.meta.mainProgram} ${lib.concatStringsSep " " cfg.extraOptions} > ${cfg.outFile}
	''; in {
		path = [ pkgs.smartmontools pkgs.nvme-cli ];
		description = "S.M.A.R.T.(nvme py) prometheus collector";
		wantedBy = [ "multi-user.target" ];
		
		serviceConfig.Type = "oneshot";
		serviceConfig.ExecStart = wrapper;
		
	};

	systemd.timers.nvme-metrics-timer = {
			wantedBy = [ "timers.target" ];
			partOf = [ "nvme-metrics.service" ];
			timerConfig.OnCalendar = "*:00/30:00";
			timerConfig.Persistent = true;
	};
	};
}