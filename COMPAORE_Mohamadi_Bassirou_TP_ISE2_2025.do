*--------------------------------------------------------------------------------------------------------------------------------------------------------------*
*                                                                               TP sur le module de STATA, dispensé par le professeur Moussa Fall              *
*--------------------------------------------------------------------------------------------------------------------------------------------------------------*

*-------------------------------------------------------------------------------*
* 1. Préparation de l'environnement de travail                                  *
*-------------------------------------------------------------------------------*
capture clear

* Afficher les tableaux en entier
set more off

* Définition du répertoire de base du projet
cd "C:\Users\user\Desktop\ISE2\S2\Stata\TP_a_rendre_STATA"

* Créer des répertoires de travail
capture mkdir "data"
capture mkdir "script"
capture mkdir "sortie"

* Fixation des répertoires de travail
global dirdata = "data"
global dirdo = "script"
global diroutput = "sortie"

* Renommons la base de données

/*En effet, le nom de notre base de données contient des espaces et peut 
  créer surement une ambiguité et des erreurs dans nos codes à venir. 
  Pour plus de prudence, nous allons le renommer en "DRC_hh_budget.dta"
*/
use "${dirdata}/DRC hh budget.dta", clear
save "${diroutput}/DRC_hh_budget.dta", replace


*-------------------------------------------------------------------------------*
*                        Exercice1                                              *
*-------------------------------------------------------------------------------*
* Chargeons la base de données sauvegardée
use "${diroutput}/DRC_hh_budget.dta", clear


* Affichage du nombre de variables et d'observations
br in 1/10
di "Nombre total de variables : " c(k)    // 22
di "Nombre total d'observations : " c(N) // 4253

* 6. Faire un résumé des valeurs manquantes pour toutes les variables

foreach var of varlist * {
    count if missing(`var')
    di "`var' : " r(N) " valeurs manquantes"
}

/*
Sur les 22 variables analysées,10 variables présentent des données manquantes. il s'agit de: 
fem_hhh, wid_hhh ,poly_hhh ,avg_adult_age , depend_ratio ,
unempl_ratio ,socp_cat_hhh , empl_type_hhh , year_educ_head ,
avg_adult_educ

*/

/*
7. Est-ce que hhid (identifiant du ménage) est unique? Donnez un rapport et
commentez
*/
duplicates report hhid

/*
8. Y a-t-il des observations manquantes et/ou erreurs de codage? Si oui, quelles
actions entreprendriez-vous?
*/

/*
Je note une différence entre observations manquantes et valeurs manquantes. 
De ce fait, les observations constituent l'ensemble des lignes du fichier de données, 
tandis que les valeurs manquantes concernent l'absence d'information pour une ou plusieurs variables dans une observation donnée.
*/
/* 

Si la question porte sur les valeurs manquantes, elle a déjà été traitée à la question 6. 
En ce qui concerne d'éventuelles erreurs de codage, nous procéderions à une vérification approfondie des modalités de chaque variable, 
puis nous recoderions les variables concernées si nécessaire afin d'assurer la cohérence et la qualité des données.

*/
*voici la liste de nos variables qualitatives: sector ,milieu ,prov ,fem_hhh ,wid_hhh ,poly_hhh ,socp_cat_hhh , empl_type_hhh 

codebook sector milieu prov fem_hhh wid_hhh poly_hhh socp_cat_hhh empl_type_hhh
br sector milieu prov fem_hhh wid_hhh poly_hhh socp_cat_hhh empl_type_hhh //visualisons uniquement les variables catégorielles

*Observons les modalités avec leur labels
tab sector
tab milieu
tab prov
tab fem_hhh
tab wid_hhh
tab poly_hhh
tab socp_cat_hhh
tab empl_type_hhh

*Observons les modalités sans leur labels
tab sector, nolabel
tab milieu, nolabel
tab prov, nolabel
tab fem_hhh, nolabel
tab wid_hhh, nolabel
tab poly_hhh, nolabel
tab socp_cat_hhh, nolabel
tab empl_type_hhh, nolabel

*sector

/*
La variable *sector* contient une erreur de codage, car certaines modalités sont redondantes en raison de différences uniquement liées à la casse ou à la langue. En effet, les modalités "Rural" et "rural" désignent la même réalité, tout comme "urbain" et "urban". Ainsi, les quatre modalités présentes ne reflètent en réalité que deux catégories distinctes : rural et urbain. Une harmonisation de ces modalités est donc nécessaire pour assurer la cohérence des données.
*/

*---------------------------------Recodage de la Variable sector

/*
Pour garder une trace de l'état initial de la variable sector, nous allons effectuer le recodage en passant par la création d'une nouvelle variable que nous allons nommer sector_recode
*/
gen sector_recode = .
replace sector_recode = 1 if sector == "rural" | sector == "Rural"
replace sector_recode = 2 if sector == "urban" | sector == "urbain"
label define sector_label 1 "Rural" 2 "Urbain"
label values sector_recode sector_label

*verification
tab sector_recode
tab sector_recode, nolabel

**9. Lister les 5 premières observations de la base
list in 1/5
*10. Lister les 10 dernières observations de la base
list in -9/l

*11. Lister les 8 personnes les plus âgées de la base
sort agehhh          // Trions la variable age par ordre croissant
list agehhh in -7/l //  Récupérons les 8 dernières valeurs

*12. Créer une nouvelle base contenant uniquement les 5 premières variables (base1)
preserve
ds
local varlist : word 1 of `r(varlist)'
local varlist `varlist' `: word 2 of `r(varlist)''
local varlist `varlist' `: word 3 of `r(varlist)''
local varlist `varlist' `: word 4 of `r(varlist)''
local varlist `varlist' `: word 5 of `r(varlist)''
keep `varlist'
save "${diroutput}/base1.dta", replace

*13. Restaurer l'ancienne base
restore

*14. Modifier le format de la variable milieu (milieu de résidence) en une nouvelle variable milieu_1
/*
Dans cette question, deux interprétations sont possibles. Premièrement, il peut s'agir de renommer la variable `milieu` en `milieu_1`, c'est-à-dire simplement changer son nom. Deuxièmement, il peut être question de modifier le **format d'affichage** de la variable, tel qu'il apparaît avec la commande `describe`. Actuellement, la variable a un format `%9.0g`, ce qui signifie que les nombres sont affichés sans décimale. Pour une meilleure lisibilité ou précision, nous pouvons modifier ce format afin d'afficher les valeurs avec des décimales, par exemple en le remplaçant par `%9.1f`. Mais cela ne change rien tout simplement parce que la variable milieu prend deux modalités : 0 et 1. Neanmoins, nous fournirons la commande necessaire pour le faire.
*/

*Changer de format. Format initial %9.0g
format milieu %9.1f

*Renommer la variable milieu en milieu_1
rename milieu milieu_1

*15. Donner le nombre d'observations dont le budget dépasse 1911318, par province (province)

*nombre d'observations dont le budget dépasse 1911318
count if budget > 1911318

*nombre d'observations dont le budget dépasse 1911318 par province 
table prov if budget > 1911318


*-------------------------------------------------------------------------------*
*                        Exercice 2                                             *
*-------------------------------------------------------------------------------*

*1.Création d'un indicateur de bien-être  WELFARE
*a. Créer une nouvelle variable ame basée sur l'âge des membres du ménage
gen ame = age18_above*1 + age12_18*0.75 + age12_below*0.5
 
*b. Compare l'équivalent adulte masculin (ame) et la taille du ménage (hhsize)
* Statistiques descriptives
summarize hhsize ame

* Corrélation
correlate hhsize ame
/*
La corrélation entre la taille du ménage (`hhsize`) et l'équivalent adulte masculin (`ame`) est de 0,9655. 
Cela indique une relation très forte et positive entre ces deux variables. Cela suggère qu'à mesure que la taille du ménage augmente, 
l'équivalent adulte masculin tend également à augmenter de manière proportionnelle. Ce résultat est attendu, car `ame` est calculé en fonction de l'âge des membres du ménage, et une taille plus grande implique généralement plus d'adultes et d'enfants. Ce lien solide montre une forte dépendance entre la taille du ménage et l'équivalent adulte, mais ne permet pas de conclure à une relation causale directe.
*/

twoway ///
    (scatter ame hhsize, ///
        msymbol(circle_hollow) msize(medium) mcolor(%50 navy)) ///
    (lfit ame hhsize, lcolor(maroon) lwidth(medium)), ///
    title("Relation entre taille du ménage et équivalent adulte (AME)", size(medsmall)) ///
    xtitle("Taille du ménage (hhsize)", size(small)) ///
    ytitle("Équivalent adulte (ame)", size(small)) ///
    xlabel(, labsize(small) grid) ///
    ylabel(, labsize(small) grid) ///
    legend(order(1 "Ménages" 2 "Tendance linéaire") size(small)) ///
    graphregion(color(white)) bgcolor(white)
	
/*
Le graphique met en évidence une relation positive entre la taille des ménages et leur équivalent adulte : plus un ménage compte de personnes, plus son équivalent adulte tend à être élevé. Cette tendance est confirmée par la droite de régression linéaire. Toutefois, on observe une certaine dispersion autour de cette tendance, ce qui signifie que des ménages de même taille peuvent avoir des compositions différentes (plus d'enfants ou d'adultes), entraînant ainsi des niveaux d'équivalent adulte variables.
*/


*c. Maintenant, créez la variable "welfare" en utilisant la formule ci-dessus et tracez un graphique pour afficher la distribution. Discutez du graphique.

gen budget_per_day = budget / 365
gen welfare = budget_per_day / ame
replace welfare = . if ame == 0

* GRAPHIQUE POUR AFFICHER LA DISTRIBUTION .

histogram welfare, ///
    bin(50) ///
    frequency ///
    color(%60 navy) ///
    title("Distribution de l'indicateur de bien-être (welfare)", ///
          size(medsmall) color(black) margin(medium)) ///
    xtitle("Welfare (budget journalier par équivalent adulte)", ///
           size(small) color(black) margin(small)) ///
    ytitle("Fréquence", ///
           size(small) color(black) margin(small)) ///
    graphregion(color(white)) ///
    plotregion(style(none)) ///
    xlabel(0(2000)20000, labsize(vsmall) angle(0) format(%9.0g)) ///
    ylabel(0(200)1600, labsize(vsmall)) ///
    xscale(range(0 20000)) ///
    yscale(range(0 1600)) ///
    xline(0, lcolor(gs8) lwidth(thin)) ///
    yline(0, lcolor(gs8) lwidth(thin)) ///
    legend(off)

*2. Nous voulons savoir dans quelle mesure cet indicateur de bien-être est corrélé avec le nombre total d'années d'éducation accumulées par le chef du ménage.(year_educ_head)

*a. Tracez un nuage de points, calculez le coefficient de corrélation et discutez
	
*Nuage de points	
twoway (scatter welfare year_educ_head, ///
        mcolor(%60 navy) msize(small)) ///
       (lfit welfare year_educ_head, lcolor(cranberry) lwidth(medium)), ///
       title("Bien-être vs. Années de scolarité du chef de ménage", size(medsmall)) ///
       xtitle("Années d'éducation du chef du ménage", size(small)) ///
       ytitle("Welfare (budget journalier par équivalent adulte)", size(small)) ///
       graphregion(color(white)) ///
       plotregion(style(none)) ///
       xlabel(, labsize(vsmall)) ///
       ylabel(, labsize(vsmall)) ///
       legend(off)
* Calcul du coefficient de corrélation
correlate welfare year_educ_head

/*
Le coefficient de corrélation de 0,3064 entre le bien-être économique (`welfare`) et les années d'éducation du chef de ménage (`year_educ_head`) indique une **corrélation positive modérée**. Cela signifie que, dans l'ensemble, les ménages dont le chef est plus instruit tendent à avoir un niveau de bien-être plus élevé. Cependant, cette relation n'est **ni forte ni parfaite** : d'autres facteurs, comme l'emploi, la composition du ménage ou les actifs détenus, peuvent aussi jouer un rôle important dans le niveau de bien-être observé. La corrélation positive suggère néanmoins qu'investir dans l'éducation peut être associé à de meilleures conditions économiques pour les ménages.
*/
*b. Créez une nouvelle variable level_educ_head en catégorisant la variable year_educ_head selon le schéma suivant, puis étiquetez la nouvelle variable.

gen level_educ_head = .

replace level_educ_head = 0 if year_educ_head == 0
replace level_educ_head = 1 if inrange(year_educ_head, 1, 6)
replace level_educ_head = 2 if inrange(year_educ_head, 7, 12)
replace level_educ_head = 3 if year_educ_head >= 13

label define educ_label  ///
    0 "No education"     ///
    1 "Primary"          ///
    2 "Secondary"        ///
    3 "Higher"

label values level_educ_head educ_label
label variable level_educ_head "Niveau d'éducation du chef de ménage"

*c. Quel est le niveau moyen de bien-être pour chacune des catégories de niveau d'éducation du chef du ménage ? Veuillez en discuter

tabstat welfare, by(level_educ_head) statistics(mean sd n) format(%9.2f)

/*
Les résultats révèlent une relation positive entre le niveau d'éducation du chef de ménage et le bien-être économique du ménage. En moyenne, les ménages dont le chef n'a reçu aucune éducation affichent le niveau de bien-être le plus faible (866), tandis que ceux dont le chef a un niveau supérieur atteignent une moyenne de 2038, soit plus du double. Cette progression suggère que l'éducation du chef de ménage est un facteur déterminant du bien-être. Toutefois, la variabilité croissante du bien-être, notamment chez les plus instruits, indique une diversité de situations économiques au sein de chaque groupe.
*/

*-------------------------------------------------------------------------------*
*                        Exercice 3                                             *
*-------------------------------------------------------------------------------*

*1. Nous voulons mieux comprendre la relation entre notre indicateur de bien-être et un certain nombre de caractéristiques des ménages.
*1.a. Estimez une régression OLS avec welfare comme variable dépendante et une sélection de variables indépendantes de votre choix. Discutez des résultats.

/*
Les variables sociodémographiques comme la taille du ménage permettent de capturer des effets structurels liés à la composition et à la vulnérabilité du foyer. Le niveau d'éducation du chef et celui des adultes reflètent le capital humain, souvent corrélé à de meilleures opportunités économiques. Les ratios de dépendance et de chômage mesurent quant à eux la pression exercée sur les membres actifs du ménage. Enfin, l'indice d'actifs constitue un indicateur direct du patrimoine matériel, souvent associé à une meilleure qualité de vie. Ces variables, prises ensemble, permettent d'appréhender de manière plus complète les déterminants du bien-être. d'ou le choix de ces variables dans le model de regression OLS.
*/
reg welfare hhsize year_educ_head avg_adult_educ depend_ratio asset, robust

*1.b. Que pouvez-vous dire sur le pouvoir prédictif et la causalité de vos résultats 

/*
Le modèle présente un pouvoir prédictif modéré, avec un R² de 0,3775, indiquant qu'environ 38 % de la variation de l'indicateur de bien-être (welfare) est expliquée par les variables retenues. Cela montre que certains déterminants importants sont capturés, mais qu'une part significative de la variabilité reste inexpliquée, probablement en raison de facteurs non observés ou non mesurés. Concernant la causalité, les résultats doivent être interprétés avec prudence : il s'agit d'une régression corrélationnelle et non d'une analyse causale stricte. L'absence de stratégie d'identification (comme un instrument, une variation exogène ou une expérimentation aléatoire) empêche d'affirmer un lien de cause à effet entre les variables explicatives et le bien-être.
*/

*2. Supposons que le seuil de pauvreté défini par le gouvernement de la RDC soit fixé à 1200 Francs Congolais (FC) par jour/adulte équivalent homme.
*2.a. Quel est le taux de pauvreté en RDC?
gen pauvre = (welfare < 1200)
mean pauvre [aw=hhweight]
/*
Le taux de pauvreté en RDC est estimé à 67,6 %, ce qui signifie que plus des deux tiers de la population vivent avec un niveau de bien-être inférieur au seuil de 1200 Francs Congolais par jour et par adulte équivalent. Ce résultat, pondéré selon les poids des ménages, met en évidence une situation préoccupante dans laquelle la majorité de la population ne dispose pas des ressources suffisantes pour satisfaire ses besoins de base.

*/

*b. Quelle est la province la plus pauvre de la RDC, et quelles sont les plus riches?
mean pauvre [aw=hhweight], over(prov)
/*
Les résultats montrent que la province la plus pauvre de la RDC est l'Équateur, avec un taux de pauvreté estimé à 86 %, suivie de près par le Kasaï-Oriental (81 %) et le Bandundu (80,6 %). En revanche, Kinshasa est la province la plus riche, avec un taux de pauvreté nettement inférieur, à 16,4 %. Ces écarts importants illustrent des inégalités régionales marquées en matière de bien-être économique à travers le pays.
*/

*c. Existe-t-il un lien entre pauvreté et éducation?
mean pauvre [aw=hhweight], over(level_educ_head)
/*
Les résultats révèlent une corrélation claire entre le niveau d'éducation du chef de ménage et la pauvreté. Les ménages dont le chef n'a aucune éducation présentent un taux de pauvreté élevé (80,9 %), suivi de ceux avec un niveau primaire (75,9 %) et secondaire (64,4 %). En revanche, les ménages dirigés par une personne ayant un niveau d'éducation supérieur affichent un taux de pauvreté bien plus faible (37,5 %). Cela suggère que l'éducation joue un rôle important dans la réduction de la pauvreté en RDC.
*/

*d. Existe-t-il un lien entre pauvreté et chômage?
correlate pauvre unempl_ratio
/*
La corrélation entre le taux de pauvreté et le taux de chômage est négative (-0.1257), bien que relativement faible. Cela signifie qu'il existe une légère relation inverse entre la pauvreté et le chômage en RDC. Autrement dit, dans les régions où le taux de chômage est plus élevé, le taux de pauvreté tend à être légèrement plus bas, et vice versa. Cependant, cette corrélation n'est pas très forte, ce qui suggère qu'il existe d'autres facteurs influençant la pauvreté qui ne sont pas directement liés au chômage.
*/
*e. Existe-t-il un lien entre pauvreté et genre?Say what a macro is for
mean pauvre [aw=hhweight], over(fem_hhh)
/*
Les résultats montrent que le taux de pauvreté est plus élevé parmi les ménages où le chef de ménage est un homme avec une moyenne de 68.6%, comparé à ceux où le chef de ménage est une femme  avec une moyenne de 62.9%. Cette différence suggère qu'il y a un taux de pauvreté légèrement plus élevé dans les ménages dirigés par des hommes. Cela pourrait indiquer des disparités économiques liées au genre dans le contexte des ménages en RDC, bien que cette relation doive être explorée plus en profondeur pour identifier les causes sous-jacentes.
*/

*3. Créez un exemple de macro et appliquez-la à une tâche
* seuil de pauvreté 
local poverty_threshold 1200

*Appliquer la macro pour calculer le taux de pauvreté :
gen pauvre_1 = (welfare < `poverty_threshold')

*Tester l'égalité des deux variables. C'est à dire la variable crée sans la macro qui est pauvre et celle crée avec la macro qui est pauvre_1

gen test_diff = pauvre_1 == pauvre
tab test_diff


***********************************************************************************************************************************
*                                                                                           FIN                                   *                                         
***********************************************************************************************************************************












