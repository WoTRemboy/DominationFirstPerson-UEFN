
using { /Fortnite.com/Devices }
using { /Fortnite.com/UI }
using { /Verse.org/Simulation }
using { /Verse.org/Assets }
using { /Verse.org/Colors }
using { /UnrealEngine.com/Temporary/SpatialMath }
using { /UnrealEngine.com/Temporary/Diagnostics }
using { /UnrealEngine.com/Temporary/UI }
using { AllRanks }

# See https://dev.epicgames.com/documentation/en-us/uefn/create-your-own-device-in-verse for how to create a verse device.

# A Verse-authored creative device that can be placed in a level
user_interface_manager := class(creative_device):

    var PlayerWidgetsMap : [player]player_widgets = map{}

    Init(Players: []player) : void =
        for ( Player : Players):
            InitializePlayerUI(Player)

    InitializePlayerUI(Player : player) : void =
        Canvas : canvas = canvas{}
        ProgressBar : custom_progress_bar = custom_progress_bar:
            Width := 175.0
            Heigth := 19.0
        ProgressBar.Init()
        CanvasSlot := canvas_slot:
            Widget := ProgressBar.GetRootWidget()
            Anchors := anchors{Minimum := vector2{X:= 0.0, Y:= 1.0}, Maximum := vector2{X:=0.0, Y:=1.0}}
            Offsets := margin{Left:=45.0, Top := -421.0}
        Canvas.AddWidget(CanvasSlot)
        PlayerWidgets := player_widgets:
            Canvas := Canvas
            ProgressBar := ProgressBar
            
        if( set PlayerWidgetsMap [Player] = PlayerWidgets, PlayerUI := GetPlayerUI[Player]):
            PlayerUI.AddWidget(Canvas)

    InitRankUI(Player : player, PlayerStats : player_stats, RankSettings : rank_settings): void=
        UpdateRank(Player, PlayerStats, RankSettings)

    UpdateRank(Player : player, PlayerStats : player_stats, RankSettings : rank_settings):void=
        RankIndex := PlayerStats.Rank
        if ( Widgets := PlayerWidgetsMap[Player], NewRank := RankSettings.Ranks[RankIndex], Image:= RankSettings.Images[RankIndex]):
            Widgets.ProgressBar.SetForegroundColor(NewRank.ForegroundColor)
            Widgets.ProgressBar.SetBackgroundColor(NewRank.BackgroundColor)
            Widgets.ProgressBar.SetRankText(NewRank.Name)
            Widgets.ProgressBar.SetImage(Image, vector2{X:= 540.0, Y:=500.0})
            UpdateProgress(Player, PlayerStats, RankSettings)

    UpdateProgress(Player : player, PlayerStats : player_stats, Rank_Settings : rank_settings): void = 
        RankIndex := PlayerStats.Rank
        if (Widgets := PlayerWidgetsMap[Player], CurrentRank := Rank_Settings.Ranks[RankIndex]):
            if ( NextRank := Rank_Settings.Ranks[RankIndex + 1]):
                Progress := 1.0 * (PlayerStats.Points - CurrentRank.PointNeeded) / (1.0 * (NextRank.PointNeeded - CurrentRank.PointNeeded))
                #if ( Rank_Settings.PointsVisible = true):
                    ProgressText := "{PlayerStats.Points}/{NextRank.PointNeeded}"
                    Widgets.ProgressBar.SetProgress(Progress, ProgressText)
                #else:
                    #Widgets.ProgressBar.SetProgress(Progress , "")
            else:
                Progress := 1.0
                #if ( Rank_Settings.PointsVisible = true):
                    ProgressText := "{PlayerStats.Points}"
                    Widgets.ProgressBar.SetProgress(Progress, ProgressText)
                #else:
                    #Widgets.ProgressBar.SetProgress(Progress , "")

player_widgets := struct:
    Canvas : canvas
    ProgressBar : custom_progress_bar

custom_progress_bar := class:
    Width : float
    Heigth : float

    RankTextureBlock : texture_block = texture_block{DefaultImage := AllRanks.Unranked}
    ColorBlockForeground : color_block = color_block{}
    ColorBlockBackground : color_block = color_block{}
    RankTextBlock : text_block = text_block{DefaultTextColor := NamedColors.White}
    ProgressTextBlock : text_block = text_block{DefaultTextColor := NamedColors.White}

    var RootWidget : widget = color_block{}

    Init() : void =
        ColorBlockForeground.SetDesiredSize(vector2{X := Width, Y := Heigth})
        ColorBlockBackground.SetDesiredSize(vector2{X := Width, Y := Heigth})
        set RootWidget = overlay:
            Slots := array:
                overlay_slot:
                    Widget := RankTextureBlock
                    HorizontalAlignment := horizontal_alignment.Center
                    Padding := margin{Right := 20.0, Top := -32.0}
                overlay_slot:
                    Widget := stack_box:
                        Orientation := orientation.Vertical
                        Slots := array:
                            stack_box_slot:
                                Widget := overlay:
                                    Slots := array:
                                        overlay_slot:
                                            Widget := ColorBlockBackground
                                            HorizontalAlignment := horizontal_alignment.Left
                                        overlay_slot:
                                            Widget := ColorBlockForeground
                                            HorizontalAlignment := horizontal_alignment.Left
                                        overlay_slot:
                                            Widget := ProgressTextBlock
                                            HorizontalAlignment := horizontal_alignment.Center

    SetProgress(InProgress : float, ProgressText : string) : void = 
        var NewProgress : float = 0.0
        if ( InProgress > 1.0) then set NewProgress = 1.0
        else if( InProgress < 0.0) then set NewProgress = 0.0
        else set NewProgress = InProgress
                                                
        NewWidth := NewProgress * Width
        ColorBlockForeground.SetDesiredSize(vector2{X:= NewWidth, Y := Heigth})
        SetProgressText(ProgressText)

    GetRootWidget(): widget = RootWidget
    SetForegroundColor(Color : color):void= ColorBlockForeground.SetColor(Color)
    SetBackgroundColor(Color : color):void= ColorBlockBackground.SetColor(Color)
    SetRankText(String : string):void = RankTextBlock.SetText(StringToMessage(String))
    SetProgressText(String : string):void= ProgressTextBlock.SetText(StringToMessage(String))
    SetImage(NewImage :texture, NewSize : vector2):void=
        RankTextureBlock.SetImage(NewImage)
        RankTextureBlock.SetDesiredSize(NewSize)

AgentToMessage<localizes>(Agent:agent):message="{Agent}"
FloatToMessage<localizes>(String : string,Float : float):message="{String}{Float}"
IntToMessage<localizes>(String : string, Integer : int):message="{String}{Integer}"
StringsToMessage<localizes>(String1 : string, String2 : string):message = "{String1}{String2}"
StringToMessage<localizes>(String : string):message= "{String}"

AllRanks<public> := module: