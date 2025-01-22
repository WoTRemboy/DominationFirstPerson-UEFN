using { /Fortnite.com/Devices }
using { /Fortnite.com/Game }
using { /Fortnite.com/Characters }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


game_manager := class(creative_device):
    @editable   PlayerStatsManager : player_stats_manager = player_stats_manager{}
    @editable   RankManager: rank_manager = rank_manager{}
    @editable   UIManager : user_interface_manager = user_interface_manager{}

    @editable   PlayerSpawners : []player_spawner_device = array{}

    var Players : []player = array{}
    
    OnBegin<override>()<suspends> : void =
        set Players = GetPlayspace().GetPlayers()
        PlayerStatsManager.Init(Players)
        UIManager.Init(Players)
        RankManager.Init(Players)
        for ( PlayerSpawner : PlayerSpawners):
            PlayerSpawner.SpawnedEvent.Subscribe(OnPlayerSpawn)

        Update()

    Update()<suspends> : void =
        sync:
            loop:
                Player := GetPlayspace().PlayerAddedEvent().Await()
                if ( not Players.Find[Player]):
                    set Players += array{Player}
                    PlayerStatsManager.InitializePlayerStats(Player)
                    UIManager.InitializePlayerUI(Player)
                    RankManager.InitializePlayerRank(Player)

            loop:
                Player := GetPlayspace().PlayerRemovedEvent().Await()
                set Players = for(CurrentPlayer : Players, CurrentPlayer <> Player) { CurrentPlayer}


    OnPlayerSpawn(Agent : agent) : void =
        if ( FortCharacter := Agent.GetFortCharacter[]):
            spawn{AwaitElimination(FortCharacter)}

    AwaitElimination(FortCharacter : fort_character)<suspends> : void =
        Result := FortCharacter.EliminatedEvent().Await()
        RankManager.HandleElimination(Result)

