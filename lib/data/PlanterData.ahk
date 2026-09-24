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

CoconutPlanters:=[["PlanterOfPlenty", 1.5, 2.25, 16/2.25] ; 3.375
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

MountainTopPlanters:=[["PlanterOfPlenty", 1.5, 2.25, 16/2.25] ; 3.375
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

PepperPlanters:=[["PlanterOfPlenty", 1.5, 2.25, 16/2.25] ; 3.375
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

StumpPlanters:=[["PlanterOfPlenty", 1.5, 2.25, 16/2.25] ; 3.375
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
