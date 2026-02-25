# nzpkg/modules/hybooru.nix
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.services.hybooru;

  # Generate the configs.json content
  configFile = pkgs.writeText "configs.json" (
    builtins.toJSON {
      port = cfg.port;
      host = cfg.host;
      hydrusDbPath = cfg.hydrusDbPath;
      appName = cfg.appName;
      appDescription = cfg.appDescription;
      adminPassword = null; # Use environment variable for secrets
      isTTY = cfg.isTTY;
      importBatchSize = cfg.importBatchSize;

      db = {
        host = cfg.database.host;
        port = cfg.database.port;
        user = cfg.database.user;
        database = cfg.database.name;
        # Password handled via environment variable
      };

      posts = {
        services = cfg.posts.services;
        filesPathOverride = cfg.posts.filesPathOverride;
        thumbnailsPathOverride = cfg.posts.thumbnailsPathOverride;
        thumbnailsMode = cfg.posts.thumbnailsMode;
        pageSize = cfg.posts.pageSize;
        cachePages = cfg.posts.cachePages;
        cacheRecords = cfg.posts.cacheRecords;
        maxPreviewSize = cfg.posts.maxPreviewSize;
      };

      tags = {
        services = cfg.tags.services;
        motd = cfg.tags.motd;
        untagged = cfg.tags.untagged;
        ignore = cfg.tags.ignore;
        blacklist = cfg.tags.blacklist;
        whitelist = cfg.tags.whitelist;
        resolveRelations = cfg.tags.resolveRelations;
        reportLoops = cfg.tags.reportLoops;
        searchSummary = cfg.tags.searchSummary;
      };

      rating =
        if cfg.rating.enable then
          {
            enabled = true;
            service = cfg.rating.service;
            stars = cfg.rating.stars;
          }
        else
          null;

      versionCheck =
        if cfg.versionCheck.enable then
          {
            enabled = true;
            owner = cfg.versionCheck.owner;
            repo = cfg.versionCheck.repo;
            cacheLifeMs = cfg.versionCheck.cacheLifeMs;
          }
        else
          null;
    }
  );

in
{
  options.services.hybooru = {
    enable = lib.mkEnableOption "Hybooru imageboard";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.nzpkg.hybooru;
      defaultText = lib.literalExpression "pkgs.nzpkg.hybooru";
      description = "The Hybooru package to use";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 3939;
      description = "HTTP server port";
    };

    host = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "HTTP server host. null listens on all interfaces.";
    };

    hydrusDbPath = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "Path to Hydrus database directory. null uses platform default.";
    };

    appName = lib.mkOption {
      type = lib.types.str;
      default = "Hybooru";
      description = "Name of your booru (appears as logo)";
    };

    appDescription = lib.mkOption {
      type = lib.types.str;
      default = "Hydrus-based booru-styled imageboard in React";
      description = "Booru's description used in OpenGraph";
    };

    adminPasswordFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = null;
      description = "File containing password for database regeneration";
    };

    isTTY = lib.mkOption {
      type = lib.types.nullOr lib.types.bool;
      default = null;
      description = "Override colorful/fancy output. null auto-determines.";
    };

    importBatchSize = lib.mkOption {
      type = lib.types.int;
      default = 8192;
      description = "Base batch size during importing. Decrease if crashes occur.";
    };

    # Database options
    database = {
      host = lib.mkOption {
        type = lib.types.str;
        default = "localhost";
        description = "Database hostname";
      };
      port = lib.mkOption {
        type = lib.types.port;
        default = 5432;
        description = "Database port";
      };
      name = lib.mkOption {
        type = lib.types.str;
        default = "hybooru";
        description = "Database name";
      };
      user = lib.mkOption {
        type = lib.types.str;
        default = "hybooru";
        description = "Database username";
      };
      passwordFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "File containing database password";
      };
    };

    # Posts options
    posts = {
      services = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf (lib.types.either lib.types.str lib.types.int));
        default = null;
        description = "List of file service names/ids to import. null imports all.";
      };
      filesPathOverride = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Override location of post files";
      };
      thumbnailsPathOverride = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Override location of thumbnails";
      };
      thumbnailsMode = lib.mkOption {
        type = lib.types.enum [
          "fit"
          "fill"
        ];
        default = "fit";
        description = "Thumbnail scale mode";
      };
      pageSize = lib.mkOption {
        type = lib.types.int;
        default = 72;
        description = "Number of posts per page";
      };
      cachePages = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Number of pages cached per cache entry";
      };
      cacheRecords = lib.mkOption {
        type = lib.types.int;
        default = 1024;
        description = "Max number of cache entries";
      };
      maxPreviewSize = lib.mkOption {
        type = lib.types.int;
        default = 104857600;
        description = "Max size in bytes for preview (default 100MB)";
      };
    };

    # Tags options
    tags = {
      services = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf (lib.types.either lib.types.str lib.types.int));
        default = null;
        description = "List of tag service names/ids to import. null imports all.";
      };
      motd = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.str (lib.types.attrsOf lib.types.str));
        default = null;
        description = "Query for random image on main page. Can be string or {light, dark, auto} attrset.";
      };
      untagged = lib.mkOption {
        type = lib.types.str;
        default = "-*";
        description = "Query to determine posts requiring tagging";
      };
      ignore = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        description = "Tags that will not be imported";
      };
      blacklist = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = null;
        description = "Posts/tags matching these will not be imported";
      };
      whitelist = lib.mkOption {
        type = lib.types.nullOr (lib.types.listOf lib.types.str);
        default = null;
        description = "Only posts matching these will be imported";
      };
      resolveRelations = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Resolve tag siblings and parents";
      };
      reportLoops = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Print detected loops in tag relationships";
      };
      searchSummary = lib.mkOption {
        type = lib.types.int;
        default = 39;
        description = "Number of tags in side menu when searching";
      };
    };

    # Rating options
    rating = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable rating import";
      };
      service = lib.mkOption {
        type = lib.types.nullOr (lib.types.either lib.types.str lib.types.int);
        default = null;
        description = "Rating service name/id. null picks any.";
      };
      stars = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Number of stars in rating";
      };
    };

    # Version check options
    versionCheck = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable version checking";
      };
      owner = lib.mkOption {
        type = lib.types.str;
        default = "funmaker";
        description = "GitHub repo owner";
      };
      repo = lib.mkOption {
        type = lib.types.str;
        default = "hybooru";
        description = "GitHub repo name";
      };
      cacheLifeMs = lib.mkOption {
        type = lib.types.int;
        default = 3600000;
        description = "Version cache lifetime in ms (default 1 hour)";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.hybooru = {
      description = "Hybooru Imageboard";
      after = [
        "network.target"
        "postgresql.service"
      ];
      wantedBy = [ "multi-user.target" ];

      preStart = ''
        # Copy config to writable state directory
        cp ${configFile} $STATE_DIRECTORY/configs.json
        chmod 600 $STATE_DIRECTORY/configs.json
      '';

      script = ''
        # Load secrets from files into environment variables
        ${lib.optionalString (cfg.database.passwordFile != null) ''
          export DB_PASSWORD="$(cat ${cfg.database.passwordFile})"
        ''}
        ${lib.optionalString (cfg.adminPasswordFile != null) ''
          export HYDRUS_ADMIN_PASSWORD="$(cat ${cfg.adminPasswordFile})"
        ''}

        export CONFIG_FILE=$STATE_DIRECTORY/configs.json

        # Run hybooru with config from state directory
        cd $STATE_DIRECTORY
        exec ${cfg.package}/bin/hybooru
      '';

      serviceConfig = {
        Type = "simple";
        StateDirectory = "hybooru";
        WorkingDirectory = "/var/lib/hybooru";
        Restart = "on-failure";
        User = "hybooru";
        Group = "hybooru";

        # Security hardening
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectSystem = "strict";
        # ProtectHome = true;
        ReadOnlyPaths = [ "/" ];
        ReadWritePaths = [
          "/var/lib/hybooru"
        ]
        ++ lib.optional (cfg.hydrusDbPath != null) cfg.hydrusDbPath
        ++ lib.optional (cfg.posts.filesPathOverride != null) cfg.posts.filesPathOverride
        ++ lib.optional (cfg.posts.thumbnailsPathOverride != null) cfg.posts.thumbnailsPathOverride;
      };
    };

    users.users.hybooru = {
      isSystemUser = true;
      group = "hybooru";
      home = "/var/lib/hybooru";
    };
    users.groups.hybooru = { };
  };
}
