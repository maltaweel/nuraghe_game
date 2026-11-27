"""Source of i18n/strings.csv (keys, en, it). Edit here or in the CSV; run this to regenerate the CSV.
Italian is a first draft by the developer: it needs a check by a native speaker before the talk."""
import csv, os
S = {}
def s(k, en, it): S[k] = (en, it)

s("TITLE", "Build a Nuraghe", "Costruisci un nuraghe")
s("SUBTITLE", "Gather your people, choose your methods and raise the tower before the seasons run out.",
  "Riunisci la tua gente, scegli i metodi e alza la torre prima che finiscano le stagioni.")
s("PLAY_L1", "Level 1: a single tower", "Livello 1: una torre")
s("PLAY_L2", "Level 2: a tower with lateral towers", "Livello 2: una torre con torri laterali")
s("HOW_TO", "How to play", "Come si gioca")
s("ABOUT", "About: evidence and guesswork", "Informazioni: prove e ipotesi")
s("SOURCES", "Sources and numbers", "Fonti e numeri")
s("LANG_SWITCH", "Italiano", "English")
s("PROTOTYPE_NOTE", "Prototype. No data is collected. Works offline.", "Prototipo. Nessun dato raccolto. Funziona offline.")
s("BACK", "Back", "Indietro")
s("NEXT", "Next", "Avanti")
s("CLOSE", "Close", "Chiudi")
s("OK", "OK", "OK")
s("GO", "Start building", "Inizia a costruire")
s("MENU", "Main menu", "Menu principale")
s("PLAY_AGAIN", "Try other choices", "Prova altre scelte")
s("SOURCE", "Source", "Fonte")
s("CHOOSE", "Choose", "Scegli")
s("THOUSANDS_SEP", ",", ".")

s("HOWTO_BODY",
"""[b]Goal:[/b] place every block of the nuraghe before the last season ends. A season is 90 working days (one year).

[b]1. Choose how to build.[/b] A quarry (near or far), a way to haul the blocks and a way to lift them. Each choice shows how strong the evidence is: MODEL, DEMONSTRATED, HYPOTHESIS or WHAT-IF. Tap [i]Source[/i] to see where it comes from.

[b]2. Gather your team.[/b] Recruit builders from your village with + and −. Every builder eats 1 kg of food a day from your stores; ox teams eat fodder. Your village is small: you cannot do it alone in time.

[b]3. Ask for help.[/b] Neighbouring villages say yes or no. They say yes more often if they trust you, are not busy with their own tower and live close. Their helpers bring their own food.

[b]4. Help them back.[/b] Neighbours will ask you for builders too. Help them and they trust you more. Refuse a village that helped you and its trust in you drops.

At the end you get [b]your strategy[/b]: a record of your choices that could one day be run in the research simulation.""",
"""[b]Obiettivo:[/b] posa tutti i blocchi del nuraghe prima che finisca l'ultima stagione. Una stagione è di 90 giorni lavorativi (un anno).

[b]1. Scegli come costruire.[/b] Una cava (vicina o lontana), un modo di trasportare i blocchi e uno di sollevarli. Ogni scelta mostra quanto è solida la prova: MODELLO, DIMOSTRATO, IPOTESI o E SE. Tocca [i]Fonte[/i] per vedere da dove viene.

[b]2. Forma la squadra.[/b] Recluta costruttori nel tuo villaggio con + e −. Ogni costruttore mangia 1 kg di cibo al giorno dalle tue scorte; i buoi mangiano foraggio. Il tuo villaggio è piccolo: da solo non ce la fai in tempo.

[b]3. Chiedi aiuto.[/b] I villaggi vicini dicono sì o no. Dicono sì più spesso se si fidano di te, se non sono occupati con la loro torre e se abitano vicino. I loro aiutanti portano il proprio cibo.

[b]4. Ricambia.[/b] Anche i vicini ti chiederanno costruttori. Se li aiuti si fidano di più. Se rifiuti un villaggio che ti ha aiutato, la sua fiducia cala.

Alla fine ricevi [b]la tua strategia[/b]: un resoconto delle tue scelte che un giorno potrebbe essere provato nella simulazione di ricerca.""")

s("ABOUT_BODY",
"""This game is based on an agent-based simulation of nuraghe construction (Repast4Py). Its labour numbers come from that model: how many person-hours it takes to quarry, haul, dress and set the stone of one tower, and how villages decide whether to help each other.

Every building method in the game carries a tag that says how strong the evidence is:""",
"""Questo gioco si basa su una simulazione ad agenti della costruzione dei nuraghi (Repast4Py). I numeri del lavoro vengono da quel modello: quante ore-persona servono per cavare, trasportare, sbozzare e posare la pietra di una torre, e come i villaggi decidono se aiutarsi.

Ogni metodo di costruzione nel gioco ha un'etichetta che dice quanto è solida la prova:""")
s("ABOUT_BODY2",
"""[b]What is guesswork in the game:[/b] the food stores, the harvest, the fodder for oxen, the cost of recruiting, the size of the neighbouring villages, how often they ask you for help and how long helpers stay. These are game rules, chosen to make a playable game. They are marked "game rule" in Sources and numbers.

[b]What the game leaves out:[/b] weather, illness, ritual, conflict, the many ways of fitting stones, and everything we do not know.

Site data: Nurnet.

Privacy: the game collects no data. It makes no network calls and uses no analytics and no cookies. Your strategy record stays on your device unless you copy or download it yourself.""",
"""[b]Cosa è ipotesi nel gioco:[/b] le scorte di cibo, il raccolto, il foraggio per i buoi, il costo del reclutamento, la grandezza dei villaggi vicini, quanto spesso ti chiedono aiuto e quanto restano gli aiutanti. Sono regole di gioco, scelte per rendere il gioco giocabile. In Fonti e numeri sono indicate come "regola di gioco".

[b]Cosa il gioco lascia fuori:[/b] il tempo atmosferico, le malattie, i riti, i conflitti, i tanti modi di incastrare le pietre e tutto ciò che non sappiamo.

Dati dei siti: Nurnet.

Privacy: il gioco non raccoglie dati. Non fa chiamate di rete e non usa statistiche né cookie. La tua strategia resta sul tuo dispositivo, a meno che tu non la copi o la scarichi.""")
s("TAG_MODEL", "MODEL", "MODELLO")
s("TAG_DEMONSTRATED", "DEMONSTRATED", "DIMOSTRATO")
s("TAG_HYPOTHESIS", "HYPOTHESIS", "IPOTESI")
s("TAG_WHATIF", "WHAT-IF", "E SE")
s("TAG_MODEL_DEMONSTRATED", "MODEL + DEMONSTRATED", "MODELLO + DIMOSTRATO")
s("TAGDESC_MODEL", "in our simulation", "nella nostra simulazione")
s("TAGDESC_DEMONSTRATED", "experimental archaeology shown, no measurements", "mostrato dall'archeologia sperimentale, senza misure")
s("TAGDESC_HYPOTHESIS", "in the literature, not in our model run", "nella letteratura, non nella nostra simulazione")
s("TAGDESC_WHATIF", "not attested", "non attestato")

s("LEVEL_1", "Level 1: a single tower", "Livello 1: una torre")
s("LEVEL_2", "Level 2: a tower with lateral towers", "Livello 2: una torre con torri laterali")
s("LEVEL_1_INTRO",
"Your village wants a nuraghe: one stone tower, 1,350 tonnes of stone in about 3,000 blocks. You have [b]%d seasons[/b] (%d working days). Your village has %d adults who can build (out of %d people).",
"Il tuo villaggio vuole un nuraghe: una torre di pietra, 1.350 tonnellate in circa 3.000 blocchi. Hai [b]%d stagioni[/b] (%d giorni lavorativi). Il tuo villaggio ha %d adulti che possono costruire (su %d persone).")
s("LEVEL_2_INTRO",
"Now a complex nuraghe: a central tower and two lateral towers, 4,050 tonnes in about 9,000 blocks. The central tower goes up first. You have [b]%d seasons[/b] (%d working days). Your village has %d adults who can build (out of %d people).",
"Ora un nuraghe complesso: una torre centrale e due torri laterali, 4.050 tonnellate in circa 9.000 blocchi. Prima si alza la torre centrale. Hai [b]%d stagioni[/b] (%d giorni lavorativi). Il tuo villaggio ha %d adulti che possono costruire (su %d persone).")
s("MODEL_NOTE", "In the simulation, 50 builders finish a single tower in about 64 working days. Your village is much smaller.",
  "Nella simulazione 50 costruttori finiscono una torre in circa 64 giorni lavorativi. Il tuo villaggio è molto più piccolo.")
s("CHOOSE_QUARRY", "1/3 Choose your quarry", "1/3 Scegli la cava")
s("CHOOSE_HAUL", "2/3 How will you haul the blocks?", "2/3 Come trasporterai i blocchi?")
s("CHOOSE_LIFT", "3/3 How will you lift the blocks?", "3/3 Come solleverai i blocchi?")
s("CHOOSE_HINT", "Numbers are person-hours (one person working one hour).", "I numeri sono ore-persona (una persona che lavora un'ora).")

s("OPT_q_near", "Near quarry: bedrock", "Cava vicina: roccia in posto")
s("OPT_q_far", "Far quarry: boulder field", "Cava lontana: campo di massi")
s("OPT_h_sledge", "Sledge and human crew", "Slitta e squadra di persone")
s("OPT_h_rollers", "Ropes and log rollers", "Funi e rulli di tronchi")
s("OPT_h_oxen", "Oxen pulling a sledge", "Buoi che tirano una slitta")
s("OPT_l_lever", "Levers, course by course", "Leve, filare per filare")
s("OPT_l_stair", "Stair inside the wall", "Scala dentro il muro")
s("OPT_l_ramp", "Earth ramp", "Rampa di terra")
s("OPT_l_pulley", "Timber frame with a pulley", "Telaio di legno con carrucola")

s("EFF_q_near", "200 m to haul. Splitting bedrock along its joints is slow: 6,280 person-hours of quarrying per tower.",
  "200 m di trasporto. Spaccare la roccia lungo le fratture è lento: 6.280 ore-persona di cava per torre.")
s("EFF_q_far", "1 km to haul, 5 times farther. Loose boulders are quick to collect: 1,132 person-hours per tower.",
  "1 km di trasporto, 5 volte più lontano. I massi sciolti si raccolgono in fretta: 1.132 ore-persona per torre.")
s("EFF_h_sledge", "6 people drag each 450 kg block at 0.27 m/s and walk back.",
  "6 persone trascinano ogni blocco di 450 kg a 0,27 m/s e tornano a piedi.")
s("EFF_h_rollers", "Game guess: 4 people per block. Nobody has measured it.",
  "Stima di gioco: 4 persone per blocco. Nessuno l'ha misurato.")
s("EFF_h_oxen", "2 ox teams and 4 drovers per block, at 0.75 m/s. Each team eats 2 kg of fodder a day (game rule), and you need enough teams.",
  "2 coppie di buoi e 4 conducenti per blocco, a 0,75 m/s. Ogni coppia mangia 2 kg di foraggio al giorno (regola di gioco), e ne servono abbastanza.")
s("EFF_l_lever", "6,537 person-hours per tower: every block is levered up the face, course by course.",
  "6.537 ore-persona per torre: ogni blocco sale lungo la parete con le leve, filare per filare.")
s("EFF_l_stair", "1,111 person-hours per tower: blocks go up a stair inside the wall; only the last metre is levered.",
  "1.111 ore-persona per torre: i blocchi salgono da una scala nel muro; solo l'ultimo metro con le leve.")
s("EFF_l_ramp", "19,141 person-hours per tower: build an earth ramp as tall as the tower, then take it away.",
  "19.141 ore-persona per torre: costruire una rampa di terra alta come la torre e poi toglierla.")
s("EFF_l_pulley", "Game guess: 1,400 person-hours per tower, plus 150 kg of stores for timber and rope.",
  "Stima di gioco: 1.400 ore-persona per torre, più 150 kg di scorte per legname e funi.")

# source cards: one line + citation, copied from the project README (Methods vignettes; What is sourced)
s("SRCLINE_q_near", "Bedrock split along joints, 11.1 ph/m³.", "Roccia spaccata lungo le fratture, 11,1 ore-persona/m³.")
s("SRC_q_near", "Spec A6.3; Boswinkel 2021, Table 7.2. Haul 200 m (Borore, Webster).", "Spec A6.3; Boswinkel 2021, Table 7.2. Trasporto 200 m (Borore, Webster).")
s("SRCLINE_q_far", "Collected boulders (scree), 2.0 ph/m³.", "Massi raccolti (detrito di versante), 2,0 ore-persona/m³.")
s("SRC_q_far", "Literature scenario S1a_scree (Boswinkel 2021, Table 7.2). The 1 km distance is the model's near-site quarry limit (1,000 m).",
  "Scenario di letteratura S1a_scree (Boswinkel 2021, Table 7.2). La distanza di 1 km è il limite del modello per le cave vicine (1.000 m).")
s("SRCLINE_h_sledge", "Sledge dragged by a human crew on dry ground.", "Slitta trascinata da una squadra di persone su terreno asciutto.")
s("SRC_h_sledge", "SCOPE rule 5; spec A6.2 (Boswinkel 2021: 124).", "SCOPE rule 5; spec A6.2 (Boswinkel 2021: 124).")
s("SRCLINE_h_rollers", "Ropes and wooden logs as rollers.", "Funi e tronchi di legno come rulli.")
s("SRC_h_rollers", "NurTime volunteer trial, Gergei, autumn 2023 (L'Unione Sarda, 13 Nov 2023, p. 21, \"Funi e tronchi per un menhir\"); photo only, no measurements. Rollers are not in the model.",
  "Prova dei volontari NurTime, Gergei, autunno 2023 (L'Unione Sarda, 13 nov 2023, p. 21, \"Funi e tronchi per un menhir\"); solo foto, nessuna misura. I rulli non sono nel modello.")
s("SRCLINE_h_oxen", "Oxen pulling a sledge.", "Buoi che tirano una slitta.")
s("SRC_h_oxen", "Literature-family scenario S3e_oxen (Boswinkel 2021: 52, 110-112), rated 2: cattle traction probably uncommon before the Late Bronze Age. Not in MR_P10; NurTime has not documented it.",
  "Scenario di letteratura S3e_oxen (Boswinkel 2021: 52, 110-112), voto 2: la trazione bovina era probabilmente rara prima del Bronzo Recente. Non in MR_P10; NurTime non l'ha documentata.")
s("SRCLINE_l_lever", "Block levered up the face, course by course.", "Blocco sollevato con le leve lungo la parete, filare per filare.")
s("SRC_l_lever", "Spec A6.6 lever rule for corridor nuraghi (Boswinkel 2021: 124); levering with wooden poles shown by NurTime at Is Perdas, Gergei, 2023 (videos on perdasnovas.it; no measurements).",
  "Spec A6.6, regola delle leve per i nuraghi a corridoio (Boswinkel 2021: 124); leve di legno mostrate da NurTime a Is Perdas, Gergei, 2023 (video su perdasnovas.it; nessuna misura).")
s("SRCLINE_l_stair", "Intramural stair, last metre levered.", "Scala nel muro, ultimo metro con le leve.")
s("SRC_l_stair", "Spec A6.6 stair rule (Laner 1999); the rule used for Nuraghe Attentu.", "Spec A6.6, regola della scala (Laner 1999); la regola usata per il Nuraghe Attentu.")
s("SRCLINE_l_ramp", "External earth ramp.", "Rampa di terra esterna.")
s("SRC_l_ramp", "Literature-family S4b_ramp (Boswinkel 2021: 122-123; Laner 1999), rated 1: a full-height ramp needs about as much material as the nuraghe (Laner 1999: 30). Not attributed to NurTime.",
  "Scenario di letteratura S4b_ramp (Boswinkel 2021: 122-123; Laner 1999), voto 1: una rampa a tutta altezza richiede circa tanto materiale quanto il nuraghe (Laner 1999: 30). Non attribuita a NurTime.")
s("SRCLINE_l_pulley", "Timber frame with a pulley.", "Telaio di legno con carrucola.")
s("SRC_l_pulley", "Not attested for Bronze Age Sardinia; never used by the model. Its cost in the game is a game rule.",
  "Non attestato nella Sardegna dell'età del Bronzo; mai usato dal modello. Il suo costo nel gioco è una regola di gioco.")

s("START_TITLE", "Your village is ready", "Il villaggio è pronto")
s("START_BODY", "With your choices the nuraghe needs about [b]%s person-hours[/b] of work. You start with %d builders; your village has %d adults.\n\nUse + and − to recruit builders (5 kg of food each to join). Watch your food. Ask the neighbours for help early.",
  "Con le tue scelte il nuraghe richiede circa [b]%s ore-persona[/b] di lavoro. Inizi con %d costruttori; il villaggio ha %d adulti.\n\nUsa + e − per reclutare costruttori (5 kg di cibo ciascuno per unirsi). Attento al cibo. Chiedi presto aiuto ai vicini.")
s("BUILDERS", "Builders", "Costruttori")
s("OX_TEAMS", "Ox teams", "Coppie di buoi")
s("ASK_HELP", "Ask a village for help", "Chiedi aiuto a un villaggio")
s("PAUSE", "Pause", "Pausa")
s("PLAY", "Play", "Gioca")
s("HUD_DAY", "Day %d/%d · Season %d/%d", "Giorno %d/%d · Stagione %d/%d")
s("HUD_STORES", "Food %s kg", "Cibo %s kg")
s("HUD_PROGRESS", "Nuraghe %d%% built · %s of %s blocks set", "Nuraghe al %d%% · %s di %s blocchi posati")
s("HUD_INFO", "Helpers %d · lent out %d · food for %d days · stone at quarry %s, at site %s",
  "Aiutanti %d · prestati %d · cibo per %d giorni · pietre in cava %s, in cantiere %s")
s("ALERT_HUNGER", "No food today: nobody worked and some builders went home.", "Niente cibo oggi: nessuno ha lavorato e alcuni costruttori sono tornati a casa.")
s("ALERT_NO_OXEN", "The blocks wait at the quarry: you need ox teams to haul them.", "I blocchi aspettano in cava: servono coppie di buoi per trasportarli.")
s("ALERT_FOOD_LOW", "Food is running low! Fewer builders, or ask for help (helpers bring their own food).", "Il cibo sta finendo! Meno costruttori, oppure chiedi aiuto (gli aiutanti portano il loro cibo).")
s("VILLAGE_hill", "Village on the hill", "Villaggio sulla collina")
s("VILLAGE_river", "Village by the river", "Villaggio sul fiume")
s("VILLAGE_plain", "Village on the plain", "Villaggio della piana")
s("VILLAGE_line_dummy", "", "")
s("VILLAGE_LINE", "%.0f km away · %d helpers · trust in you %.2f · busy for %d days · chance of yes %d%%",
  "a %.0f km · %d aiutanti · fiducia in te %.2f · occupato per %d giorni · probabilità di sì %d%%")
s("ASK_EXPLAIN", "A village says yes more often if it trusts you, is not busy with its own tower and lives close. Helpers stay 10 days and bring their own food.",
  "Un villaggio dice sì più spesso se si fida di te, non è occupato con la sua torre e abita vicino. Gli aiutanti restano 10 giorni e portano il loro cibo.")
s("ASK", "Ask", "Chiedi")
s("ASK_WAIT", "Ask again in %d days", "Richiedi tra %d giorni")
s("ASK_YES_T", "They said yes!", "Hanno detto sì!")
s("ASK_YES", "%s sends %d helpers for %d days.", "%s manda %d aiutanti per %d giorni.")
s("ASK_NO_T", "They said no", "Hanno detto no")
s("ASK_NO", "%s cannot help now. Maybe they are busy, far away, or do not trust you enough yet.", "%s ora non può aiutarti. Forse è occupato, lontano, o non si fida ancora abbastanza.")
s("REQ_T", "A neighbour asks for help", "Un vicino chiede aiuto")
s("REQ_BODY", "%s asks you for %d of your builders for %d days.", "%s ti chiede %d dei tuoi costruttori per %d giorni.")
s("REQ_NOTE_OWE", "They helped you before. If you refuse, their trust in you drops (−0.2). If you help, it rises (+0.1).",
  "Ti hanno già aiutato. Se rifiuti, la loro fiducia in te cala (−0,2). Se aiuti, sale (+0,1).")
s("REQ_NOTE_FREE", "If you help, their trust in you rises (+0.1) and they say yes more often later.",
  "Se aiuti, la loro fiducia in te sale (+0,1) e in seguito diranno sì più spesso.")
s("REQ_YES", "Send them builders", "Manda i costruttori")
s("REQ_NO", "Refuse", "Rifiuta")
s("SEASON_T", "Season %d is over", "La stagione %d è finita")
s("SEASON_BODY", "The year turns. The harvest refills your stores: +%s kg of food. The nuraghe is %d%% built. Season %d of %d begins.",
  "L'anno gira. Il raccolto riempie le scorte: +%s kg di cibo. Il nuraghe è al %d%%. Inizia la stagione %d di %d.")
s("WIN_T", "The nuraghe stands!", "Il nuraghe è in piedi!")
s("LOSE_T", "The season ended — the walls stand unfinished", "La stagione è finita: i muri restano incompiuti")
s("WIN_BODY", "You set the last block on working day %d of %d.", "Hai posato l'ultimo blocco nel giorno lavorativo %d di %d.")
s("LOSE_BODY", "The nuraghe is %d%% built; %s blocks are still missing.", "Il nuraghe è al %d%%; mancano ancora %s blocchi.")
s("END_STATS", "Work done: %s person-hours. You asked for help %d times (%d yes). Neighbours asked you %d times; you helped %d times.",
  "Lavoro fatto: %s ore-persona. Hai chiesto aiuto %d volte (%d sì). I vicini ti hanno chiesto %d volte; hai aiutato %d volte.")
s("END_METHODS", "Your methods and their evidence:", "I tuoi metodi e le loro prove:")
s("END_NOT_MODEL", "You used a method that is not in the simulation, so its cost here is a game rule, not a model result.",
  "Hai usato un metodo che non è nella simulazione: il suo costo qui è una regola di gioco, non un risultato del modello.")
s("STRATEGY_T", "Your strategy", "La tua strategia")
s("STRATEGY_BODY", "This is a record of your choices and what happened, written in the terms of the simulation's settings. It stays on your device: nothing is sent anywhere. You can copy it or save it as a file.",
  "Questo è il resoconto delle tue scelte e di cosa è successo, scritto nei termini delle impostazioni della simulazione. Resta sul tuo dispositivo: non viene inviato da nessuna parte. Puoi copiarlo o salvarlo come file.")
s("COPY", "Copy", "Copia")
s("COPIED", "Copied to your clipboard.", "Copiato negli appunti.")
s("DOWNLOAD", "Save as file", "Salva come file")
s("SAVED_AT", "Saved on this device: %s", "Salvato su questo dispositivo: %s")

s("SOURCES_BODY", open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "sources_en.bbcode")).read(),
  open(os.path.join(os.path.dirname(os.path.abspath(__file__)), "sources_it.bbcode")).read())

del S["VILLAGE_line_dummy"]
out = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "i18n", "strings.csv")
with open(out, "w", newline="", encoding="utf-8") as f:
    w = csv.writer(f, quoting=csv.QUOTE_MINIMAL)
    w.writerow(["keys", "en", "it"])
    for k, (en, it) in S.items():
        w.writerow([k, en, it])
print(len(S), "keys ->", out)
