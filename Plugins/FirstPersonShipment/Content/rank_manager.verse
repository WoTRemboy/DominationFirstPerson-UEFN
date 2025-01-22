
using { /Fortnite.com/Devices }
using { /Fortnite.com/Characters }
using { /Fortnite.com/Game }
using { /Verse.org/Simulation }
using { /UnrealEngine.com/Temporary/Diagnostics }


rank_manager := class(creative_device):
    @editable   Settings : rank_settings = rank_settings{}
    @editable   PlayerStatsManager : player_stats_manager = player_stats_manager{}

    Init(Players : []player) : void =
        for ( Player : Players):
            InitializePlayerRank(Player)

    InitializePlayerRank(Player : player) : void =
        {}

    HandleElimination(ElimResult : elimination_result) : void =
        EliminatedCharacter := ElimResult.EliminatedCharacter
        MaybeEliminatingCharacter := ElimResult.EliminatingCharacter
        # Who was eliminated
        if ( Player := player[EliminatedCharacter.GetAgent[]]):
            UpdateEliminatedPlayerStats(Player)

        # Who eliminated player
        if:
            EliminatingCharacter := MaybeEliminatingCharacter?
            EliminatingCharacter <> EliminatedCharacter
            Agent := EliminatingCharacter.GetAgent[]
            Player := player[Agent]
        then:
            UpdateEliminatingPlayerStats(Player)

    UpdateEliminatingPlayerStats(Player : player) : void =
        PlayerStats := PlayerStatsManager.GetPlayerStats(Player)
        NewEliminations := PlayerStats.Eliminations + 1
        NewPoints := PlayerStats.Points + 1
        NewRank := CalculatePlayerRankUp(PlayerStats, NewPoints)
        NewStats := PlayerStatsManager.UpdateStats(Player, NewEliminations, NewPoints, NewRank)

    UpdateEliminatedPlayerStats(Player : player) : void =
        PlayerStats := PlayerStatsManager.GetPlayerStats(Player)
        NewPoints := PlayerStats.Points - 1 >= 0 and PlayerStats.Points - 1 or 0
        NewEliminations := PlayerStats.Eliminations
        NewRank := CalculatePlayerRankDown(PlayerStats, NewPoints)
        NewStats := PlayerStatsManager.UpdateStats(Player, NewEliminations, NewPoints, NewRank)

    CalculatePlayerRankUp(OldStats : player_stats, NewPoints : int) : int =
        CurrentRankIndex := OldStats.Rank
        if ( NextRank := Settings.Ranks[CurrentRankIndex + 1]):
            if ( NewPoints >= NextRank.PointNeeded):
                Print("Ranked up!")
                return CurrentRankIndex + 1

        CurrentRankIndex

    CalculatePlayerRankDown(OldStats : player_stats, NewPoints : int) : int =
        CurrentRankIndex := OldStats.Rank
        if ( CurrentRank := Settings.Ranks[CurrentRankIndex]):
            if ( NewPoints < CurrentRank.PointNeeded):
                return CurrentRankIndex - 1
        CurrentRankIndex

rank := class<concrete>:
    @editable   Name : string = "Rank"
    @editable   PointNeeded : int = 0

rank_settings := class<concrete>:
    @editable   Ranks : []rank = array{}
