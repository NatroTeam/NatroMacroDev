nectarnames:=["Comforting", "Refreshing", "Satisfying", "Motivating", "Invigorating"]
planternames:=["PlasticPlanter", "CandyPlanter", "BlueClayPlanter", "RedClayPlanter", "TackyPlanter", "PesticidePlanter", "HeatTreatedPlanter", "HydroponicPlanter", "PetalPlanter", "PlanterOfPlenty", "PaperPlanter", "TicketPlanter"]
fieldnames:=["dandelion", "sunflower", "mushroom", "blueflower", "clover", "strawberry", "spider", "bamboo", "pineapple", "stump", "cactus", "pumpkin", "pinetree", "rose", "mountaintop", "pepper", "coconut"]

ComfortingFields:=["Dandelion", "Bamboo", "Pine Tree"]
RefreshingFields:=["Coconut", "Strawberry", "Blue Flower"]
SatisfyingFields:=["Pineapple", "Sunflower", "Pumpkin"]
MotivatingFields:=["Stump", "Spider", "Mushroom", "Rose"]
InvigoratingFields:=["Pepper", "Mountain Top", "Clover", "Cactus"]

;field planters ordered from best to worst (will always try to pick the best planter for the field)
;planters that provide no bonuses at all are ordered by worst to best so it can preserve the "better" planters for other nectar types
;planters array: [1] planter name, [2] nectar bonus, [3] speed bonus, [4] hours to complete growth (no field degradation is assumed) (rounded up 2 d.p.)
;assumed: hydroponic 40% faster near blue flowers, heat-treated 40% faster near red flowers
BambooPlanters:=[["HydroponicPlanter", 1.4, 1.375, 8.73] ; 1.925
	, ["PetalPlanter", 1.5, 1.125, 12.45] ; 1.6875
	, ["PesticidePlanter", 1, 1.6, 6.25] ; 1.6
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["BlueClayPlanter", 1.2, 1.1875, 5.06] ; 1.425
	, ["TackyPlanter", 1.25, 1, 8] ; 1.25
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["RedClayPlanter", 1, 1, 6] ; 1
	, ["HeatTreatedPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

BlueFlowerPlanters:=[["HydroponicPlanter", 1.4, 1.345, 8.93] ; 1.883
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["TackyPlanter", 1, 1.5, 5.34] ; 1.5
	, ["BlueClayPlanter", 1.2, 1.1725, 5.12] ; 1.407
	, ["PetalPlanter", 1, 1.155, 12.13] ; 1.155
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["RedClayPlanter", 1, 1, 6] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["HeatTreatedPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 1

CactusPlanters:=[["HeatTreatedPlanter", 1.4, 1.215, 9.88] ; 1.701
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["RedClayPlanter", 1.2, 1.1075, 5.42] ; 1.29
	, ["HydroponicPlanter", 1, 1.25, 9.6] ; 1.25
	, ["BlueClayPlanter", 1, 1.125, 5.34] ; 1.125
	, ["PetalPlanter", 1, 1.035, 13.53] ; 1.035
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

CloverPlanters:=[["HeatTreatedPlanter", 1.4, 1.17, 10.26] ; 1.638
	, ["TackyPlanter", 1, 1.5, 5.34] ; 1.5
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["RedClayPlanter", 1.2, 1.085, 5.53] ; 1.302
	, ["HydroponicPlanter", 1, 1.17, 10.57] ; 1.17
	, ["PetalPlanter", 1, 1.16, 12.07] ; 1.16
	, ["BlueClayPlanter", 1, 1.085, 5.53] ; 1.085
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

CoconutPlanters:=[["PlanterOfPlenty", 1.5, 1.5, 10.67] ; 2.25
	, ["CandyPlanter", 1, 1.5, 2.67] ; 1.5
	, ["PetalPlanter", 1, 1.447, 9.68] ; 1.447
	, ["HydroponicPlanter", 1.4, 1.023, 11.74] ; 1.4322
	, ["BlueClayPlanter", 1.2, 1.0115, 5.94] ; 1.2138
	, ["HeatTreatedPlanter", 1, 1.03, 11.66] ; 1.03
	, ["RedClayPlanter", 1, 1.015, 5.92] ; 1.015
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

DandelionPlanters:=[["PetalPlanter", 1.5, 1.4235, 9.84] ; 2.13525
	, ["TackyPlanter", 1.25, 1.5, 5.33] ; 1.875
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["HydroponicPlanter", 1.4, 1.0485, 11.45] ; 1.4679
	, ["BlueClayPlanter", 1.2, 1.02425, 5.86] ; 1.2291
	, ["HeatTreatedPlanter", 1, 1.028, 11.68] ; 1.028
	, ["RedClayPlanter", 1, 1.014, 5.92] ; 1.014
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

MountainTopPlanters:=[["PlanterOfPlenty", 1.5, 1.5, 10.67] ; 2.25
	, ["HeatTreatedPlanter", 1.4, 1.25, 9.6] ; 1.75
	, ["RedClayPlanter", 1.2, 1.125, 5.34] ; 1.35
	, ["HydroponicPlanter", 1, 1.25, 9.6] ; 1.25
	, ["BlueClayPlanter", 1, 1.125, 5.34] ; 1.125
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["PetalPlanter", 1, 1, 14] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

MushroomPlanters:=[["HeatTreatedPlanter", 1.4, 1.3425, 8.94] ; 1.8795
	, ["TackyPlanter", 1, 1.5, 5.34] ; 1.5
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["CandyPlanter", 1.2, 1, 4] ; 1.2
	, ["RedClayPlanter", 1, 1.17125, 5.12] ; 1.17125
	, ["PetalPlanter", 1, 1.1575, 12.1] ; 1.1575
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["BlueClayPlanter", 1, 1, 6] ; 1
	, ["HydroponicPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 1

PepperPlanters:=[["PlanterOfPlenty", 1.5, 1.5, 10.67] ; 2.25
	, ["HeatTreatedPlanter", 1.4, 1.46, 8.22] ; 2.044
	, ["RedClayPlanter", 1.2, 1.23, 4.88] ; 1.476
	, ["PetalPlanter", 1, 1.04, 13.47] ; 1.04
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["BlueClayPlanter", 1, 1, 6] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["HydroponicPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

PineTreePlanters:=[["HydroponicPlanter", 1.4, 1.42, 8.46] ; 1.988
	, ["PetalPlanter", 1.5, 1.08, 12.97] ; 1.62
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["BlueClayPlanter", 1.2, 1.21, 4.96] ; 1.452
	, ["TackyPlanter", 1.25, 1, 8] ; 1.25
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["RedClayPlanter", 1, 1, 6] ; 1
	, ["PesticidePlanter", 1, 1, 10] ; 1
	, ["HeatTreatedPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

PineapplePlanters:=[["PetalPlanter", 1.5, 1.445, 9.69] ; 2.1675
	, ["CandyPlanter", 1, 1.5, 2.67] ; 1.5
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["TackyPlanter", 1.25, 1, 8] ; 1.25
	, ["RedClayPlanter", 1.2, 1.015, 5.92] ; 1.218
	, ["HeatTreatedPlanter", 1, 1.03, 11.66] ; 1.03
	, ["HydroponicPlanter", 1, 1.025, 11.71] ; 1.025
	, ["BlueClayPlanter", 1, 1.0125, 5.93] ; 1.0125
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

PumpkinPlanters:=[["PetalPlanter", 1.5, 1.285, 10.9] ; 1.9275
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["RedClayPlanter", 1.2, 1.055, 5.69] ; 1.266
	, ["TackyPlanter", 1.25, 1, 8] ; 1.25
	, ["HeatTreatedPlanter", 1, 1.11, 10.82] ; 1.11
	, ["HydroponicPlanter", 1, 1.105, 10.86] ; 1.105
	, ["BlueClayPlanter", 1, 1.0525, 5.71] ; 1.0525
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

RosePlanters:=[["HeatTreatedPlanter", 1.4, 1.41, 8.52] ; 1.974
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["RedClayPlanter", 1, 1.205, 4.98] ; 1.205
	, ["CandyPlanter", 1.2, 1, 4] ; 1.2
	, ["PetalPlanter", 1, 1.09, 12.85] ; 1.09
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["BlueClayPlanter", 1, 1, 6] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["HydroponicPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

SpiderPlanters:=[["PesticidePlanter", 1.3, 1.6, 6.25] ; 2.08
	, ["PetalPlanter", 1, 1.5, 9.33] ; 1.5
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["HeatTreatedPlanter", 1.4, 1, 12] ; 1.4
	, ["CandyPlanter", 1.2, 1, 4] ; 1.2
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["BlueClayPlanter", 1, 1, 6] ; 1
	, ["RedClayPlanter", 1, 1, 6] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["HydroponicPlanter", 1, 1, 12] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

StrawberryPlanters:=[["PesticidePlanter", 1, 1.6, 6.25] ; 1.6
	, ["CandyPlanter", 1, 1.5, 2.67] ; 1.5
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["HydroponicPlanter", 1.4, 1, 12] ; 1.3
	, ["HeatTreatedPlanter", 1, 1.345, 8.93] ; 1.345
	, ["BlueClayPlanter", 1.2, 1, 6] ; 1.2
	, ["RedClayPlanter", 1, 1.1725, 5.12] ; 1.1725
	, ["PetalPlanter", 1, 1.155, 12.13] ; 1.155
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

StumpPlanters:=[["PlanterOfPlenty", 1.5, 1.5, 10.67] ; 2.25
	, ["HeatTreatedPlanter", 1.4, 1.03, 11.65] ; 1.442
	, ["HydroponicPlanter", 1, 1.375, 8.73] ; 1.375
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["CandyPlanter", 1.2, 1, 4] ; 1.2
	, ["BlueClayPlanter", 1, 1.1875, 5.06] ; 1.1875
	, ["PetalPlanter", 1, 1.095, 12.79] ; 1.095
	, ["RedClayPlanter", 1, 1.015, 5.92] ; 1.015
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["TackyPlanter", 1, 1, 8] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

SunflowerPlanters:=[["PetalPlanter", 1.5, 1.3415, 10.44] ; 2.01225
	, ["TackyPlanter", 1.25, 1.5, 5.34] ; 1.875
	, ["PlanterOfPlenty", 1.5, 1, 16] ; 1.5
	, ["PesticidePlanter", 1.3, 1, 10] ; 1.3
	, ["RedClayPlanter", 1.2, 1.04175, 5.76] ; 1.2501
	, ["HeatTreatedPlanter", 1, 1.0835, 11.08] ; 1.0835
	, ["HydroponicPlanter", 1, 1.075, 11.17] ; 1.075
	, ["BlueClayPlanter", 1, 1.0375, 5.79] ; 1.0375
	, ["PlasticPlanter", 1, 1, 2] ; 1
	, ["CandyPlanter", 1, 1, 4] ; 1
	, ["PaperPlanter", .75, 1, 1] ; 0.75
	, ["TicketPlanter", 2, 1, 2]] ; 2

;quest data
QuestBarGapSize := 10
QuestBarSize := 50
QuestBarInset := 16

;map: quest name, [objective array]
PolarBear := Map("Aromatic Pie",
		[[3,"Kill","Mantis"]
		,[4,"Kill","Ladybugs"]
		,[1,"Collect","Rose"]
		,[2,"Collect","Pine Tree"]]

	, "Beetle Brew",
		[[3,"Kill","Ladybugs"]
		,[4,"Kill","RhinoBeetles"]
		,[1,"Collect","Pineapple"]
		,[2,"Collect","Dandelion"]]

	, "Candied Beetles",
		[[3,"Kill","RhinoBeetles"]
		,[1,"Collect","Strawberry"]
		,[2,"Collect","Blue Flower"]]

	, "Exotic Salad",
		[[1,"Collect","Cactus"]
		,[2,"Collect","Rose"]
		,[3,"Collect","Blue Flower"]
		,[4,"Collect","Clover"]]

	, "Extreme Stir-Fry",
		[[6,"Kill","Werewolf"]
		,[5,"Kill","Scorpions"]
		,[4,"Kill","Spider"]
		,[1,"Collect","Cactus"]
		,[2,"Collect","Bamboo"]
		,[3,"Collect","Dandelion"]]

	, "High Protein",
		[[4,"Kill","Spider"]
		,[3,"Kill","Scorpions"]
		,[2,"Kill","Mantis"]
		,[1,"Collect","Sunflower"]]

	, "Ladybug Poppers",
		[[2,"Kill","Ladybugs"]
		,[1,"Collect","Blue Flower"]]

	, "Mantis Meatballs",
		[[2,"Kill","Mantis"]
		,[1,"Collect","Pine Tree"]]

	, "Prickly Pears",
		[[1,"Collect","Cactus"]]

	, "Pumpkin Pie",
		[[3,"Kill","Mantis"]
		,[1,"Collect","Pumpkin"]
		,[2,"Collect","Sunflower"]]

	, "Scorpion Salad",
		[[2,"Kill","Scorpions"]
		,[1,"Collect","Rose"]]

	, "Spiced Kebab",
		[[3,"Kill","Werewolf"]
		,[1,"Collect","Clover"]
		,[2,"Collect","Bamboo"]]

	, "Spider Pot-Pie",
		[[2,"Kill","Spider"]
		,[1,"Collect","Mushroom"]]

	, "Spooky Stew",
		[[4,"Kill","Werewolf"]
		,[3,"Kill","Spider"]
		,[1,"Collect","Spider"]
		,[2,"Collect","Mushroom"]]

	, "Strawberry Skewers",
		[[3,"Kill","Scorpions"]
		,[1,"Collect","Strawberry"]
		,[2,"Collect","Bamboo"]]

	, "Teriyaki Jerky",
		[[3,"Kill","Werewolf"]
		,[1,"Collect","Pineapple"]
		,[2,"Collect","Spider"]]

	, "Thick Smoothie",
		[[1,"Collect","Strawberry"]
		,[2,"Collect","Pumpkin"]]

	, "Trail Mix",
		[[1,"Collect","Sunflower"]
		,[2,"Collect","Pineapple"]]

	; TODO: PETALDETECT
	, "Petal Tabbouleh",
		[[1, "Collect", "Pineapple"]
		, [2, "Collect", "Strawberry"]
		, [3, "Kill", "RhinoBeetles"]]

	, "Mashed Blooms",
		[[1, "Collect", "Pumpkin"]
		,[2, "Collect", "Spider"]
		,[3, "Collect", "Bamboo"]
		,[4, "Kill", "Spider"]]
)

BlackBear := Map("Just White",
		[[1,"Collect","White"]]

	, "Just Red",
		[[1,"Collect","Red"]]

	, "Just Blue",
		[[1,"Collect","Blue"]]

	, "A Bit Of Both",
		[[1,"Collect","Red"]
		,[2,"Collect","Blue"]]

	, "Any Pollen",
		[[1,"Collect","Any"]]

	, "The Whole Lot",
		[[1,"Collect","Red"]
		,[2,"Collect","Blue"]
		,[3,"Collect","White"]]

	, "Between The Bamboo",
		[[2,"Collect","Bamboo"]
		,[1,"Collect","Blue"]]

	, "Play In The Pumpkins",
		[[2,"Collect","Pumpkin"]
		,[1,"Collect","White"]]

	, "Plundering Pineapples",
		[[2,"Collect","Pineapple"]
		,[1,"Collect","Any"]]

	, "Stroll In The Strawberries",
		[[2,"Collect","Strawberry"]
		,[1,"Collect","Red"]]

	, "Mid-Level Mission",
		[[1,"Collect","Spider"]
		,[2,"Collect","Strawberry"]
		,[3,"Collect","Bamboo"]]

	, "Blue Flower Bliss",
		[[1,"Collect","Blue Flower"]]

	, "Delve Into Dandelions",
		[[1,"Collect","Dandelion"]]

	, "Fun In The Sunflowers",
		[[1,"Collect","Sunflower"]]

	, "Mission For Mushrooms",
		[[1,"Collect","Mushroom"]]

	, "Leisurely Lowlands",
		[[1,"Collect","Sunflower"]
		,[2,"Collect","Dandelion"]
		,[3,"Collect","Mushroom"]
		,[4,"Collect","Blue Flower"]]

	, "Triple Trek",
		[[1,"Collect","Mountain Top"]
		,[2,"Collect","Pepper"]
		,[3,"Collect","Coconut"]]

	, "Pepper Patrol",
		[[1,"Collect","Pepper"]])


BuckoBee := Map("Abilities",
		[[1,"Collect","Any"]]

	, "Bamboo",
		[[1,"Collect","Bamboo"]]

	, "Bombard",
		[[4,"Get","Ant"]
		,[3,"Get","Ant"]
		,[2,"Kill","RhinoBeetles"]
		,[1,"Collect","Any"]]

	, "Booster",
		[[2,"Get","BlueBoost"]
		,[1,"Collect","Any"]]

	, "Clean-Up",
		[[1,"Collect","Blue Flower"]
		,[2,"Collect","Bamboo"]
		,[3,"Collect","Pine Tree"]]

	, "Extraction",
		[[1,"Collect","Clover"]
		,[2,"Collect","Cactus"]
		,[3,"Collect","Pumpkin"]]

	, "Flowers",
		[[1,"Collect","Blue Flower"]]

	, "Goo",
		[[1,"Collect","Blue"]]

	, "Medley",
		[[2,"Collect","Bamboo"]
		,[3,"Collect","Pine Tree"]
		,[1,"Collect","Any"]]

	, "Picnic",
		[[5,"Get","Ant"]
		,[4,"Get","Ant"]
		,[3,"Feed","Blueberry"]
		,[1,"Collect","Blue Flower"]
		,[2,"Collect","Blue"]]

	, "Pine Trees",
		[[1,"Collect","Pine Tree"]]

	, "Pollen",
		[[1,"Collect","Blue"]]

	, "Scavenge",
		[[1,"Collect","Blue"]
		,[3,"Collect","Blue"]
		,[2,"Collect","Any"]]

	, "Skirmish",
		[[2,"Kill","RhinoBeetles"]
		,[1,"Collect","Blue Flower"]]

	, "Tango",
		[[3,"Kill","Mantis"]
		,[1,"Collect","Blue"]
		,[2,"Collect","Any"]]

	, "Tour",
		[[5,"Kill","Mantis"]
		,[4,"Kill","RhinoBeetles"]
		,[1,"Collect","Blue Flower"]
		,[2,"Collect","Bamboo"]
		,[3,"Collect","Pine Tree"]]

	, "Petals",
		[[1,"Collect","Pine Tree"]
		,[2,"Collect","Clover"]
		,[3,"Collect","Pineapple"]])


RileyBee := Map("Abilities",
		[[1,"Collect","Any"]]

	, "Booster",
		[[2,"Get","RedBoost"]
		,[1,"Collect","Any"]]

	, "Clean-Up",
		[[1,"Collect","Mushroom"]
		,[2,"Collect","Strawberry"]
		,[3,"Collect","Rose"]]

	, "Extraction",
		[[1,"Collect","Clover"]
		,[2,"Collect","Cactus"]
		,[3,"Collect","Pumpkin"]]

	, "Goo",
		[[1,"Collect","Red"]]

	, "Medley",
		[[2,"Collect","Strawberry"]
		,[3,"Collect","Rose"]
		,[1,"Collect","Any"]]

	, "Mushrooms",
		[[1,"Collect","Mushroom"]]

	, "Picnic",
		[[4,"Get","Ant"]
		,[3,"Feed","Strawberry"]
		,[1,"Collect","Mushroom"]
		,[2,"Collect","Strawberry"]]

	, "Pollen",
		[[1,"Collect","Red"]]

	, "Rampage",
		[[3,"Get","Ant"]
		,[2,"Kill","Ladybugs"]
		,[1,"Kill","All"]]

	, "Roses",
		[[1,"Collect","Rose"]]

	, "Scavenge",
		[[1,"Collect","Red"]
		,[3,"Collect","Strawberry"]
		,[2,"Collect","Any"]]

	, "Skirmish",
		[[2,"Kill","Ladybugs"]
		,[1,"Collect","Mushroom"]]

	, "Strawberries",
		[[1,"Collect","Strawberry"]]

	, "Tango",
		[[3,"Kill","Scorpions"]
		,[1,"Collect","Red"]
		,[2,"Collect","Any"]]

	, "Tour",
		[[5,"Kill","Scorpions"]
		,[4,"Kill","Ladybugs"]
		,[1,"Collect","Mushroom"]
		,[2,"Collect","Strawberry"]
		,[3,"Collect","Rose"]]

	, "Petals",
		[[1,"Collect","Strawberry"]
		,[2,"Collect","Clover"]
		,[3,"Collect","Spider"]]
)

;field booster data
FieldBooster:=Map("pine tree", {booster:"blue", stacks:1}
	, "bamboo", {booster:"blue", stacks:1}
	, "blue flower", {booster:"blue", stacks:3}
	, "stump", {booster:"blue", stacks:1}
	, "rose", {booster:"red", stacks:1}
	, "strawberry", {booster:"red", stacks:1}
	, "mushroom", {booster:"red", stacks:3}
	, "pepper", {booster:"red", stacks:1}
	, "sunflower", {booster:"mountain", stacks:3}
	, "dandelion", {booster:"mountain", stacks:3}
	, "spider", {booster:"mountain", stacks:2}
	, "clover", {booster:"mountain", stacks:2}
	, "pineapple", {booster:"mountain", stacks:2}
	, "pumpkin", {booster:"mountain", stacks:1}
	, "cactus", {booster:"mountain", stacks:1}
	, "mountain top", {booster:"none", stacks:0}
	, "coconut", {booster:"none", stacks:0})

;Gumdrops carried me, they so pro
CommandoChickHealth := Map(3, 150
	, 4, 2000
	, 5, 10000
	, 6, 15000
	, 7, 25000
	, 8, 50000
	, 9, 100000
	, 10, 150000
	, 11, 200000
	, 12, 300000
	, 13, 400000
	, 14, 500000
	, 15, 750000
	, 16, 1000000
	, 17, 2500000
	, 18, 5000000
	, 19, 7500000)

; Hive slot walk distances
slotMove := [
	[{dir:"Right", dist:4}, {dir:["Right", "Fwd"], dist:20}],
	[{dir:["Fwd", "Right"], dist:13}, {dir:"Fwd", dist:6}],
	[{dir:"Fwd", dist:20}, {dir:"Back", dist:4}],
	[{dir:["Left", "Fwd"], dist:13}, {dir:"Fwd", dist:6}],
	[{dir:"Left", dist:4}, {dir:["Left", "Fwd"], dist:20}],
	[{dir:["Left", "Fwd"], dist:12}, {dir:"Left", dist:13}, {dir:["Left", "Fwd"], dist:10}]
]


nm_importConfig()
{
	global
	local config := Map() ; store default values, these are loaded initially

	config["Settings"] := Map("GuiTheme", "MacLion3"
		, "AlwaysOnTop", 0
		, "MoveSpeedNum", 28
		, "MoveMethod", "Cannon"
		, "SprinklerType", "Supreme"
		, "ConvertBalloon", "Gather"
		, "ConvertMins", 30
		, "LastConvertBalloon", 1
		, "DisableToolUse", 0
		, "AnnounceGuidingStar", 0
		, "NewWalk", 1
		, "HiveSlot", 6
		, "HiveBees", 50
		, "PrivServer", ""
		, "FallbackServer1", ""
		, "FallbackServer2", ""
		, "FallbackServer3", ""
		, "ReconnectMethod", "Deeplink"
		, "ClaimMethod", "ToSlot"
		, "ReconnectInterval", ""
		, "ReconnectHour", ""
		, "ReconnectMin", ""
		, "PublicFallback", 1
		, "GuiX", ""
		, "GuiY", ""
		, "GuiTransparency", 0
		, "BuffDetectReset", 0
		, "ClickCount", 1000
		, "ClickDelay", 10
		, "ClickMode", 1
		, "ClickDuration", 50
		, "KeyDelay", 20
		, "StartHotkey", "F1"
		, "PauseHotkey", "F2"
		, "StopHotkey", "F3"
		, "AutoClickerHotkey", "F4"
		, "TimersHotkey", "F5"
		, "ShowOnPause", 0
		, "IgnoreUpdateVersion", ""
		, "IgnoreIncorrectRobloxSettings", 0
		, "FDCWarn", 1
		, "EnableBeesmasTime", 0
		, "HideErrors", 1
		, "DebugHotkey", "F6"
		, "ReleaseChannel", "Stable"
	)

	config["Status"] := Map("StatusLogReverse", 0
		, "TotalRuntime", 0
		, "SessionRuntime", 0
		, "TotalGatherTime", 0
		, "SessionGatherTime", 0
		, "TotalConvertTime", 0
		, "SessionConvertTime", 0
		, "TotalViciousKills", 0
		, "SessionViciousKills", 0
		, "TotalBossKills", 0
		, "SessionBossKills", 0
		, "TotalBugKills", 0
		, "SessionBugKills", 0
		, "TotalPlantersCollected", 0
		, "SessionPlantersCollected", 0
		, "TotalQuestsComplete", 0
		, "SessionQuestsComplete", 0
		, "TotalDisconnects", 0
		, "SessionDisconnects", 0
		, "DiscordMode", 0
		, "DiscordCheck", 0
		, "Webhook", ""
		, "BotToken", ""
		, "MainChannelCheck", 1
		, "MainChannelID", ""
		, "ReportChannelCheck", 1
		, "ReportChannelID", ""
		, "WebhookEasterEgg", 0
		, "ssCheck", 0
		, "ssDebugging", 0
		, "CriticalSSCheck", 1
		, "AmuletSSCheck", 1
		, "MachineSSCheck", 1
		, "BalloonSSCheck", 1
		, "ViciousSSCheck", 1
		, "DeathSSCheck", 1
		, "PlanterSSCheck", 1
		, "HoneySSCheck", 0
		, "criticalCheck", 0
		, "discordUID", ""
		, "discordUIDCommands", ""
		, "CriticalErrorPingCheck", 1
		, "DisconnectPingCheck", 1
		, "GameFrozenPingCheck", 1
		, "PhantomPingCheck", 1
		, "UnexpectedDeathPingCheck", 0
		, "EmergencyBalloonPingCheck", 0
		, "commandPrefix", "?"
		, "NightAnnouncementCheck", 0
		, "NightAnnouncementName", ""
		, "NightAnnouncementPingID", ""
		, "NightAnnouncementWebhook", ""
		, "DebugLogEnabled", 1
		, "SessionTotalHoney", 0
		, "HoneyAverage", 0
		, "HoneyUpdateSSCheck", 1)

	config["Gather"] := Map("FieldName1", "Sunflower"
		, "FieldName2", "None"
		, "FieldName3", "None"
		, "FieldPattern1", "Squares"
		, "FieldPattern2", "Lines"
		, "FieldPattern3", "Lines"
		, "FieldPatternSize1", "M"
		, "FieldPatternSize2", "M"
		, "FieldPatternSize3", "M"
		, "FieldPatternReps1", 3
		, "FieldPatternReps2", 3
		, "FieldPatternReps3", 3
		, "FieldPatternShift1", 0
		, "FieldPatternShift2", 0
		, "FieldPatternShift3", 0
		, "FieldPatternInvertFB1", 0
		, "FieldPatternInvertFB2", 0
		, "FieldPatternInvertFB3", 0
		, "FieldPatternInvertLR1", 0
		, "FieldPatternInvertLR2", 0
		, "FieldPatternInvertLR3", 0
		, "FieldUntilMins1", 20
		, "FieldUntilMins2", 15
		, "FieldUntilMins3", 15
		, "FieldUntilPack1", 95
		, "FieldUntilPack2", 95
		, "FieldUntilPack3", 95
		, "FieldReturnType1", "Walk"
		, "FieldReturnType2", "Walk"
		, "FieldReturnType3", "Walk"
		, "FieldSprinklerLoc1", "Center"
		, "FieldSprinklerLoc2", "Center"
		, "FieldSprinklerLoc3", "Center"
		, "FieldSprinklerDist1", 10
		, "FieldSprinklerDist2", 10
		, "FieldSprinklerDist3", 10
		, "FieldRotateDirection1", "None"
		, "FieldRotateDirection2", "None"
		, "FieldRotateDirection3", "None"
		, "FieldRotateTimes1", 1
		, "FieldRotateTimes2", 1
		, "FieldRotateTimes3", 1
		, "FieldDriftCheck1", 1
		, "FieldDriftCheck2", 1
		, "FieldDriftCheck3", 1
		, "CurrentFieldNum", 1)

config["Collect"] := Map("ClockCheck", 1
		, "LastClock", 1
		, "MondoBuffCheck", 0
		, "MondoAction", "Buff"
		, "MondoLootDirection", "Random"
		, "LastMondoBuff", 1
		, "AntPassCheck", 0
		, "AntPassBuyCheck", 0
		, "AntPassAction", "Pass"
		, "LastAntPass", 1
		, "RoboPassCheck", 0
		, "LastRoboPass", 1
		, "HoneystormCheck", 0
		, "LastHoneystorm", 1
		, "HoneyDisCheck", 0
		, "LastHoneyDis", 1
		, "TreatDisCheck", 0
		, "LastTreatDis", 1
		, "BlueberryDisCheck", 0
		, "LastBlueberryDis", 1
		, "StrawberryDisCheck", 0
		, "LastStrawberryDis", 1
		, "CoconutDisCheck", 0
		, "LastCoconutDis", 1
		, "RoyalJellyDisCheck", 0
		, "LastRoyalJellyDis", 1
		, "GlueDisCheck", 0
		, "LastGlueDis", 1
		, "LastBlueBoost", 1
		, "LastRedBoost", 1
		, "LastMountainBoost", 1
		, "BeesmasGatherInterruptCheck", 0
		, "StockingsCheck", 0
		, "LastStockings", 1
		, "WreathCheck", 0
		, "LastWreath", 1
		, "FeastCheck", 0
		, "LastFeast", 1
		, "RBPDelevelCheck", 0
		, "LastRBPDelevel", 1
		, "GingerbreadCheck", 0
		, "LastGingerbread", 1
		, "SnowMachineCheck", 0
		, "LastSnowMachine", 1
		, "CandlesCheck", 0
		, "LastCandles", 1
		, "SamovarCheck", 0
		, "LastSamovar", 1
		, "LidArtCheck", 0
		, "LastLidArt", 1
		, "GummyBeaconCheck", 0
		, "LastGummyBeacon", 1
		, "MonsterRespawnTime", 0
		, "BugrunInterruptCheck", 0
		, "BugrunLadybugsCheck", 0
		, "BugrunLadybugsLoot", 0
		, "LastBugrunLadybugs", 1
		, "BugrunRhinoBeetlesCheck", 0
		, "BugrunRhinoBeetlesLoot", 0
		, "LastBugrunRhinoBeetles", 1
		, "BugrunSpiderCheck", 0
		, "BugrunSpiderLoot", 0
		, "LastBugrunSpider", 1
		, "BugrunMantisCheck", 0
		, "BugrunMantisLoot", 0
		, "LastBugrunMantis", 1
		, "BugrunScorpionsCheck", 0
		, "BugrunScorpionsLoot", 0
		, "LastBugrunScorpions", 1
		, "BugrunWerewolfCheck", 0
		, "BugrunWerewolfLoot", 0
		, "LastBugrunWerewolf", 1
		, "TunnelBearCheck", 0
		, "TunnelBearBabyCheck", 0
		, "LastTunnelBear", 1
		, "KingBeetleCheck", 0
		, "KingBeetleBabyCheck", 0
		, "KingBeetleAmuletMode", 1
		, "LastKingBeetle", 1
		, "InputSnailHealth", 100.00
		, "SnailTime", 15
		, "InputChickHealth", 100.00
		, "ChickLevel", 10
		, "ChickTime", 15
		, "StumpSnailCheck", 0
		, "ShellAmuletMode", 1
		, "LastStumpSnail", 1
		, "CommandoCheck", 0
		, "LastCommando", 1
		, "CocoCrabCheck", 0
		, "LastCocoCrab", 1
		, "StingerCheck", 0
		, "StingerPepperCheck", 1
		, "StingerMountainTopCheck", 1
		, "StingerRoseCheck", 1
		, "StingerCactusCheck", 1
		, "StingerSpiderCheck", 1
		, "StingerCloverCheck", 1
		, "StingerDailyBonusCheck", 0
		, "VBLastKilled", 1
		, "MondoSecs", 120
		, "NormalMemoryMatchCheck", 0
		, "LastNormalMemoryMatch", 1
		, "MegaMemoryMatchCheck", 0
		, "LastMegaMemoryMatch", 1
		, "ExtremeMemoryMatchCheck", 0
		, "LastExtremeMemoryMatch", 1
		, "NightMemoryMatchCheck", 0
		, "LastNightMemoryMatch", 1
		, "WinterMemoryMatchCheck", 0
		, "LastWinterMemoryMatch", 1
		, "MicroConverterMatchIgnore", 0
		, "SunflowerSeedMatchIgnore", 0
		, "JellyBeanMatchIgnore", 0
		, "RoyalJellyMatchIgnore", 0
		, "TicketMatchIgnore", 0
		, "CyanTrimMatchIgnore", 0
		, "OilMatchIgnore", 0
		, "StrawberryMatchIgnore", 0
		, "CoconutMatchIgnore", 0
		, "TropicalDrinkMatchIgnore", 0
		, "RedExtractMatchIgnore", 0
		, "MagicBeanMatchIgnore", 0
		, "PineappleMatchIgnore", 0
		, "StarJellyMatchIgnore", 0
		, "EnzymeMatchIgnore", 0
		, "BlueExtractMatchIgnore", 0
		, "GumdropMatchIgnore", 0
		, "FieldDiceMatchIgnore", 0
		, "MoonCharmMatchIgnore", 0
		, "BlueberryMatchIgnore", 0
		, "GlitterMatchIgnore", 0
		, "StingerMatchIgnore", 0
		, "TreatMatchIgnore", 0
		, "GlueMatchIgnore", 0
		, "CloudVialMatchIgnore", 0
		, "SoftWaxMatchIgnore", 0
		, "HardWaxMatchIgnore", 0
		, "SwirledWaxMatchIgnore", 0
		, "NightBellMatchIgnore", 0
		, "HoneysuckleMatchIgnore", 0
		, "SuperSmoothieMatchIgnore", 0
		, "SmoothDiceMatchIgnore", 0
		, "NeonberryMatchIgnore", 0
		, "GingerbreadMatchIgnore", 0
		, "SilverEggMatchIgnore", 0
		, "GoldEggMatchIgnore", 0
		, "DiamondEggMatchIgnore", 0
		, "MemoryMatchInterruptCheck", 0
		, "StickerPrinterCheck", 0
		, "LastStickerPrinter", 1
		, "StickerPrinterEgg", "Basic")

    config["Blender"] := Map("BlenderRot", 1
		, "BlenderCheck", 1
		, "TimerInterval", 0
		, "BlenderItem1", "None"
		, "BlenderItem2", "None"
		, "BlenderItem3", "None"
		, "BlenderAmount1", 0
		, "BlenderAmount2", 0
		, "BlenderAmount3", 0
		, "BlenderIndex1", 1
		, "BlenderIndex2", 1
		, "BlenderIndex3", 1
		, "BlenderTime1", 0
		, "BlenderTime2", 0
		, "BlenderTime3", 0
		, "BlenderEnd",  0
		, "LastBlenderRot", 1
		, "BlenderCount1", 0
		, "BlenderCount2", 0
		, "BlenderCount3", 0)

	config["Shrine"] := Map("ShrineCheck", 0
		, "LastShrine", 1
		, "ShrineAmount1", 0
		, "ShrineAmount2", 0
		, "ShrineItem1", "None"
		, "ShrineItem2", "None"
		, "ShrineIndex1", 1
		, "ShrineIndex2", 1
		, "ShrineRot", 1)

	config["Boost"] := Map("FieldBoostStacks", 0
		, "FieldBooster1", "None"
		, "FieldBooster2", "None"
		, "FieldBooster3", "None"
		, "BoostChaserCheck", 0
		, "HotbarWhile2", "Never"
		, "HotbarWhile3", "Never"
		, "HotbarWhile4", "Never"
		, "HotbarWhile5", "Never"
		, "HotbarWhile6", "Never"
		, "HotbarWhile7", "Never"
		, "FieldBoosterMins", 15
		, "HotbarTime2", 900
		, "HotbarTime3", 900
		, "HotbarTime4", 900
		, "HotbarTime5", 900
		, "HotbarTime6", 900
		, "HotbarTime7", 900
		, "HotbarMax2", 0
		, "HotbarMax3", 0
		, "HotbarMax4", 0
		, "HotbarMax5", 0
		, "HotbarMax6", 0
		, "HotbarMax7", 0
		, "LastHotkey2", 1
		, "LastHotkey3", 1
		, "LastHotkey4", 1
		, "LastHotkey5", 1
		, "LastHotkey6", 1
		, "LastHotkey7", 1
		, "LastWhirligig", 1
		, "LastEnzymes", 1
		, "LastGlitter", 1
		, "LastMicroConverter", 1
		, "LastGuid", 1
		, "AutoFieldBoostActive", 0
		, "AutoFieldBoostRefresh", 12.5
		, "AFBDiceEnable", 0
		, "AFBGlitterEnable", 0
		, "AFBFieldEnable", 0
		, "AFBDiceHotbar", "None"
		, "AFBGlitterHotbar", "None"
		, "AFBDiceLimitEnable", 1
		, "AFBGlitterLimitEnable", 1
		, "AFBHoursLimitEnable", 0
		, "AFBDiceLimit", 1
		, "AFBGlitterLimit", 1
		, "AFBHoursLimit", .01
		, "FieldLastBoosted", 1
		, "FieldLastBoostedBy", "None"
		, "FieldNextBoostedBy", "None"
		, "AFBdiceUsed", 0
		, "AFBglitterUsed", 0
		, "BlueFlowerBoosterCheck", 1
		, "BambooBoosterCheck", 1
		, "PineTreeBoosterCheck", 1
		, "DandelionBoosterCheck", 1
		, "SunflowerBoosterCheck", 1
		, "CloverBoosterCheck", 1
		, "SpiderBoosterCheck", 1
		, "PineappleBoosterCheck", 1
		, "CactusBoosterCheck", 1
		, "PumpkinBoosterCheck", 1
		, "MushroomBoosterCheck", 1
		, "StrawberryBoosterCheck", 1
		, "RoseBoosterCheck", 1
		, "PepperBoosterCheck", 1
		, "StumpBoosterCheck", 1
		, "CoconutBoosterCheck", 0
		, "StickerStackCheck", 0
		, "LastStickerStack", 1
		, "StickerStackItem", "Tickets"
		, "StickerStackMode", 0
		, "StickerStackTimer", 900
		, "StickerStackHive", 0
		, "StickerStackCub", 0
		, "StickerStackVoucher", 0)

	config["Quests"] := Map("QuestGatherMins", 5
		, "QuestGatherReturnBy", "Walk"
		, "QuestBoostCheck", 0
		, "PolarQuestCheck", 0
		, "PolarQuestGatherInterruptCheck", 1
		, "PolarQuestProgress", "Unknown"
		, "HoneyQuestCheck", 0
		, "HoneyQuestProgress", "Unknown"
		, "BlackQuestCheck", 0
		, "BlackQuestProgress", "Unknown"
		, "LastBlackQuest", 1
		, "BrownQuestCheck", 0
		, "BrownQuestProgress", "Unknown"
		, "LastBrownQuest", 1
		, "BuckoQuestCheck", 0
		, "BuckoQuestGatherInterruptCheck", 1
		, "BuckoQuestProgress", "Unknown"
		, "RileyQuestCheck", 0
		, "RileyQuestGatherInterruptCheck", 1
		, "RileyQuestProgress", "Unknown")

	config["Planters"] := Map("LastComfortingField", "None"
		, "LastRefreshingField", "None"
		, "LastSatisfyingField", "None"
		, "LastMotivatingField", "None"
		, "LastInvigoratingField", "None"
		, "MPlanterGatherA", 0
		, "MPlanterGather1", 0
		, "MPlanterGather2", 0
		, "MPlanterGather3", 0
		, "MPlanterHold1", 0
		, "MPlanterHold2", 0
		, "MPlanterHold3", 0
		, "MPlanterSmoking1", 0
		, "MPlanterSmoking2", 0
		, "MPlanterSmoking3", 0
		, "MPuffModeA", 0
		, "MPuffMode1", 0
		, "MPuffMode2", 0
		, "MPuffMode3", 0
		, "MConvertFullBagHarvest", 0
		, "MGatherPlanterLoot", 1
		, "PlanterHarvestNow1", 0
		, "PlanterHarvestNow2", 0
		, "PlanterHarvestNow3", 0
		, "PlanterSS1", 0
		, "PlanterSS2", 0
		, "PlanterSS3", 0
		, "LastPlanterGatherSlot", 3
		, "PlanterName1", "None"
		, "PlanterName2", "None"
		, "PlanterName3", "None"
		, "PlanterField1", "None"
		, "PlanterField2", "None"
		, "PlanterField3", "None"
		, "PlanterHarvestTime1", 2147483647
		, "PlanterHarvestTime2", 2147483647
		, "PlanterHarvestTime3", 2147483647
		, "PlanterNectar1", "None"
		, "PlanterNectar2", "None"
		, "PlanterNectar3", "None"
		, "PlanterEstPercent1", 0
		, "PlanterEstPercent2", 0
		, "PlanterEstPercent3", 0
		, "PlanterGlitter1", 0
		, "PlanterGlitter2", 0
		, "PlanterGlitter3", 0
		, "PlanterGlitterC1", 0
		, "PlanterGlitterC2", 0
		, "PlanterGlitterC3", 0
		, "PlanterHarvestFull1", ""
		, "PlanterHarvestFull2", ""
		, "PlanterHarvestFull3", ""
		, "PlanterManualCycle1", 1
		, "PlanterManualCycle2", 1
		, "PlanterManualCycle3", 1
		, "PlanterMode", 0
		, "nPreset", "Blue"
		, "MaxAllowedPlanters", 3
		, "n1priority", "Comforting"
		, "n2priority", "Motivating"
		, "n3priority", "Satisfying"
		, "n4priority", "Refreshing"
		, "n5priority", "Invigorating"
		, "n1minPercent", 70
		, "n2minPercent", 80
		, "n3minPercent", 80
		, "n4minPercent", 80
		, "n5minPercent", 40
		, "HarvestInterval", 2
		, "AutomaticHarvestInterval", 0
		, "HarvestFullGrown", 0
		, "GotoPlanterField", 0
		, "GatherFieldSipping", 0
		, "ConvertFullBagHarvest", 0
		, "GatherPlanterLoot", 1
		, "PlasticPlanterCheck", 1
		, "CandyPlanterCheck", 1
		, "BlueClayPlanterCheck", 1
		, "RedClayPlanterCheck", 1
		, "TackyPlanterCheck", 1
		, "PesticidePlanterCheck", 1
		, "HeatTreatedPlanterCheck", 0
		, "HydroponicPlanterCheck", 0
		, "PetalPlanterCheck", 0
		, "PaperPlanterCheck", 0
		, "TicketPlanterCheck", 0
		, "PlanterOfPlentyCheck", 0
		, "BambooFieldCheck", 0
		, "BlueFlowerFieldCheck", 1
		, "CactusFieldCheck", 1
		, "CloverFieldCheck", 1
		, "CoconutFieldCheck", 0
		, "DandelionFieldCheck", 1
		, "MountainTopFieldCheck", 0
		, "MushroomFieldCheck", 0
		, "PepperFieldCheck", 1
		, "PineTreeFieldCheck", 1
		, "PineappleFieldCheck", 1
		, "PumpkinFieldCheck", 0
		, "RoseFieldCheck", 1
		, "SpiderFieldCheck", 1
		, "StrawberryFieldCheck", 1
		, "StumpFieldCheck", 0
		, "SunflowerFieldCheck", 1
		, "TimerGuiTransparency", 0
		, "TimerX", 150
		, "TimerY", 150
		, "TimersOpen", 0)

	local k, v, i, j
	for k,v in config ; load the default values as globals, will be overwritten if a new value exists when reading
		for i,j in v
			%i% := j

	local inipath := A_WorkingDir "\settings\nm_config.ini"

	if FileExist(inipath) { ; update default values with new ones read from any existing .ini
		;nm_ReadIni(inipath)
		nm_ReadBaselineIni(inipath)
	}

	local ini := ""
	for k,v in config ; overwrite any existing .ini with updated one with all new keys and old values
	{
		ini .= "[" k "]`r`n"
		for i in v
			ini .= i "=" %i% "`r`n"
		ini .= "`r`n"
	}

	local file := FileOpen(inipath, "w-d")
	file.Write(ini), file.Close()
}