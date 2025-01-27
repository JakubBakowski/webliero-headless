(async function () {
  console.log("Starting WebLiero room...");
  
  // Admin key will be replaced by entrypoint script
  const adminKey = "ADMIN_KEY_PLACEHOLDER";
  console.log("Admin key configured:", adminKey);
  
  // Initialize the room
  const room = window.WLInit({
    token: window.WLTOKEN, // This will be set by the launcher
    roomName: "🎮 Infrastructure Gdansk Room",
    maxPlayers: 12,
    public: true,
    password: "volue2000",
    geo: { lat: 54.35, lon: 18.65, code: "pl" } // Gdansk, Poland
  });

  window.WLROOM = room;

  // Basic room settings
  room.setSettings({
    gameMode: "dm",
    scoreLimit: 20,
    timeLimit: 10,
    respawnDelay: 3,
    damageMultiplier: 3.0,
    forceRamdomizeWeapons: true,
    // Level settings
    levelPool: "arenasBest",
    expandLevel: false,
    
    // Weapon settings
    reloadWeaponsOnSpawn: true,
    lockWeaponsDuringMatch: false,
    maxDuplicateWeapons: 0,
    
    // Bonus settings
    bonusDrops: "healthAndWeapons",
    bonusSpawnFrequency: 30
  });

  // Event handlers
  room.onRoomLink = (link) => {
    console.log("Room link:", link);
  };

  room.onPlayerJoin = (player) => {
    console.log(`${player.name} joined the room`);
    
    // Check if player is admin
    if (player.auth === adminKey) {
      room.setPlayerAdmin(player.id, true);
      console.log(`${player.name} was granted admin rights`);
    }
  };

  room.onPlayerLeave = (player) => {
    console.log(`${player.name} left the room`);
  };

  room.onPlayerChat = (player, message) => {
    console.log(`<${player.name}> ${message}`);
    
    // Help command
    if (message.toLowerCase() === "!help") {
      const helpText = [
        "Available commands:",
        "!help - Show this help message",
        "!settings - Show current room settings",
        "Admin commands:",
        "!map - Restart current map",
        "!dm - Switch to deathmatch mode",
        "!tdm - Switch to team deathmatch mode"
      ];
      
      helpText.forEach(line => {
        room.sendAnnouncement(line, player.id, 0x00FF00);
      });
      return false;
    }

    // Settings command
    if (message.toLowerCase() === "!settings") {
      const settings = room.getSettings();
      console.log("Current settings object:", JSON.stringify(settings, null, 2));
      
      const settingsText = [
        "Current room settings:",
        `Game Mode: ${settings.gameMode}`,
        `Score Limit: ${settings.scoreLimit}`,
        `Time Limit: ${settings.timeLimit}`,
        `Respawn Delay: ${settings.respawnDelay}`,
        `Damage Multiplier: ${settings.damageMultiplier}x`
      ];
      
      settingsText.forEach(line => {
        room.sendAnnouncement(line, player.id, 0x00FF00);
      });
      return false;
    }
    
    // Admin commands
    if (player.admin) {
      if (message.startsWith("!map")) {
        room.restartGame();
        room.sendAnnouncement("Admin restarted the map", null, 0xFFFF00);
        console.log("Admin requested map restart");
        return false;
      }

      if (message === "!dm") {
        const settings = room.getSettings();
        settings.gameMode = "dm";
        room.setSettings(settings);
        room.sendAnnouncement("Game mode changed to Deathmatch", null, 0xFFFF00);
        return false;
      }

      if (message === "!tdm") {
        const settings = room.getSettings();
        settings.gameMode = "tdm";
        room.setSettings(settings);
        room.sendAnnouncement("Game mode changed to Team Deathmatch", null, 0xFFFF00);
        return false;
      }
    }
    
    return true; // Allow other messages to be shown
  };

  room.onGameStart = (byPlayer) => {
    const starter = byPlayer ? byPlayer.name : "Auto";
    console.log(`New game started by ${starter}`);
  };

  room.onGameEnd = (scores) => {
    console.log("Game ended with scores:", scores);
  };

  room.onCaptcha = () => {
    console.error("Invalid token - please check your WEBLIERO_TOKEN");
  };

})(); 