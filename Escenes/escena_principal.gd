extends Node2D

var progres :int;
var busActual :int;
var seleccionat :int;
var llistatEsperants :Array;
var spritesViandants :Array;
var potEntrar :bool;
var texteActiu :bool;
var multipleActiu :bool;
var regexBBcode :RegEx;
var escenaCotxe :PackedScene;
var escenaViandant :PackedScene;

enum {PERSONATGE, BUS, TEXTE, MULTIPLE, SKIP}
enum {ADVENTURER, FEMALE, MALE, SOLDIER, ZOMBIE}
enum {ESQUERRA, DRETA}
enum {VIANDANT, COTXE}

@onready var tempNouEsdeveniment = $TempsNouEsdeveniment;
@onready var tempAleatori = $TempEsdevenimentAleatori;
@onready var contenidorEtiqueta = $ContenidorTexte;
@onready var rectFadeIn = $FadeInCanvas/RectFadeIn;
@onready var etiqueta = $ContenidorTexte/Texte;
@onready var tempSortidaBus = $TempSortidaBus;
@onready var canvasFadeIn = $FadeInCanvas;
@onready var jugador = $PersonatgeJugador;
@onready var reproductorFX = $SFXPlayer;
@onready var jumpscare = $Jumpscare;
@onready var autobus = $Tusgsal;


const esdeveniments = [
#	[0.1, SKIP, 40], # DEBUG
	[2.0, PERSONATGE, 0, ESQUERRA, FEMALE],
	[0.1, TEXTE, "[color=yellow]Bon vespre!"],
	[0.1, TEXTE, "[color=yellow]Fa fred, eh?"],
	[0.1, MULTIPLE, ["Sí, una mica.", "Doncs et veig en màniga curta."],
			["[color=yellow]Almenys, s'hi està millor que fa un any.",
			"[color=yellow]No he agafat abric aquest matí."], [1,0]],
	[0.1, TEXTE, "[color=yellow]Ja saps, fa bon dia quan surts de casa, i no hi penses."],
	[0.5, TEXTE, "[color=yellow]Portes aqui gaire estona? Quin bus esperes?"],
	[1.0, TEXTE, "[color=yellow]La [color=blue]N5[/color], eh? L'app diu que encara queda."],
	[2.5, TEXTE, "..."],
	[2.5, TEXTE, "[color=yellow]Oh, sembla que el meu ja arriba. Adéu!"],
	[0.5, BUS], # BUS 0
	[2.5, PERSONATGE, 2, DRETA, ADVENTURER],
	[1.0, TEXTE, "[i]Oh, és l'Albert... Però sembla que no m'ha vist."],
	[0.1, MULTIPLE, ["...", "Bona nit, Albert!"], 
			["...","[color=blue]Ai ondia hola Àlex, no t'havia vist, vaig tot despistat."], [0,6]],
	[1.5, TEXTE, "[i]Oh, aqui ve un altre bus."],
	[0.5, TEXTE, "[i]No, sembla que no és el meu."],
	[0.5, BUS], # BUS 1
	[0.1, PERSONATGE, 4, DRETA, FEMALE],
	[0.1, TEXTE, "[color=red]No! No, no, no! Se m'ha escapat als nassos. Merda."],
	[0.1, SKIP, 20],
	[0.1, TEXTE, "[color=blue]Tot bé? A aquesta hora, deus ser ben cansat."],
	[0.1, MULTIPLE, ["Ja ho pots ben dir","No creguis, no he fet gairebé res en tot el dia"],
			["[color=blue]Es clar, haver d'agafar el nitbus és una feinada.",
			"[color=blue]Quina enveja, jo vinc de fer dos torns avui a la feina."], [0,0]],
	[0.1, TEXTE, "[color=pink]Albert! Àlex! Hola i adéu!"],
	[0.1, PERSONATGE, 1, DRETA, MALE],
	[0.1, TEXTE, "[color=pink]Vinc i me'n vaig, que aqui ve el meu bus!"],
	[0.1, TEXTE, "[color=blue]Òndia, tio, Jaume! Afanya't! Bon viatge!"],
	[0.1, BUS], # BUS 1
	[1.0, MULTIPLE, ["[i]... Aquest qui era?[/i]","Aquest noi feia batxi amb nosaltres, oi?",
			"Ai, el Jaume sempre amb pressa."], ["[color=blue]No el recordes? Anava al nostre institut.",
			"[color=blue]Sí, el que anava a l'altra classe.","[color=blue]Ja veus, sempre amunt i avall."],
			[0,2,4]],
	[0.1, TEXTE, "[color=blue]Va venir en començar batxillerat. Anava a l'altra classe."],
	[0.5, MULTIPLE, ["Ara que ho dius, em sona un Jaume, però no gaire.","No, ni idea."],
			["[color=blue]És normal, va passar poc temps a l'institut.",
			"[color=blue]Ai, doncs una llàstima, és molt bon paio."],[8,8]],
	[0.1, TEXTE, "[color=blue]Feia temps que no el veia. Espero que li vagi tot bé."],
	[0.1, SKIP, 6],
	[0.1, TEXTE, "[color=blue]Potser és per això que-"],
	[0.1, TEXTE, "[color=blue]Ai tu! Saps de què em vais assabentar?"],
	[0.1, TEXTE, "[color=blue]El Marc n'estava [rainbow]penjadíssim[/rainbow] d'ell."],
	[0.1, MULTIPLE, ["No fotis.", "Ah, ja. Tothom ho sabia."],
			["[color=blue]Sí sí sí. M'ho va dir la Laia fent unes birres.",
			"[color=blue]Com? Doncs jo no en tenia ni idea."], [0,2]],
	[0.1, TEXTE, "[color=blue]Però sembla que es pensava que ja tenia xicota."],
	[0.1, MULTIPLE, ["Com? No estava sortint amb l'Elena?","Aix, aquestes coses pasen..."],
			["[color=blue]No, que va! Només eren veins!","[color=blue]Calla, que tu ets el menys indicat."],
			[0,0]],
	[0.5, TEXTE, "[color=blue]Au va, amb tanta xarrameca, ja hi és el bus."],
	[0.1, TEXTE, "[color=blue]A reveure, Àlex!"],
	[1.0, BUS], # BUS 2
	[1.5, PERSONATGE, 3, ESQUERRA, SOLDIER],
	[1.0, TEXTE, "[color=green]¿Ké [wave][i]pasha[/i][/wave] ermano?"],
	[.75, MULTIPLE, ["[i]Millor no faig cas.[/i]", "Bon vespre."],
			["[color=green]...", "[color=green]Coñe, disculpa jefe, yo creyendo que eras el Manu."],
			[0, 9]], 
	[1.0, TEXTE, "[color=green]Oye tú yo ke te hecho pa ke me ignore, ¿eh?"],
	[0.5, TEXTE, "[color=green]¿Te insultao? ¿Te pegao? ¿A ti que te pasa, eh?"],
	[0.1, TEXTE, "[color=green]Que yo no [wave][i]t'echo[/i][/wave] ná tio he llegao he saludao y ya."],
	[0.5, MULTIPLE, ["Uy, perdona, no te habia oído.","[i]Millor segueixo sense fer cas.[/i]"],
			["[color=green]No me venga con esas ahora, que he visto como te lo pensabas.",
			"[color=green]Mira tío que te parta un rayo."], [0,4]],
	[0.1, TEXTE, "[color=green]La caja esa gris en que decia ignorarme o \"Bon vespre\"."],
	[0.1, TEXTE, "[color=green]¿Que te crees que he nacío ayer eh?"],
	[0.3, PERSONATGE, 3, DRETA, ZOMBIE],
	[0.5, TEXTE, "[color=green]Anda mira tío te dejo en paz que si no la tenemos."],
	[1.0, SKIP, 6], #GOTO BUS 3
	[0.1, TEXTE, "[color=green]Que con lo oscuro que está to esto te he confundío."],
	[0.5, PERSONATGE, 4, DRETA, ZOMBIE],
	[1.0, TEXTE, "[color=green]Oye [wave][i]picha[/i][/wave], ¿no tendrá un piti?"],
	[0.1, TEXTE, "[color=green]Que aqui en la calle esperando uno pilla frío, sabes."],
	[0.1, MULTIPLE, ["Toma.","Que va, no fumo."], ["[color=green]Dios te lo pague, hermano.",
			"[color=green]No pasa ná, tú sigue así, que esto mata."], [0,0]],
	[2.0, TEXTE, "[color=green]Anda mira, aqui viene. Buenas noche premo."],
	[1.0, BUS], # BUS 3
	[1.5, PERSONATGE, 4, ESQUERRA, FEMALE],
	[1.5, TEXTE, "[color=lightblue]Una vergonya."],
	[.75, TEXTE, "[color=lightblue]Em sembla una absoluta una vergonya."],
	[.75, TEXTE, "[color=lightblue]La gestió dels busos d'aquesta ciutat és una vergonya."],
	[1.0, TEXTE, "[color=lightblue]Mira, fins fa un any, tot això anava bé."],
	[0.1, TEXTE, "[color=lightblue]... [tornado]\"bé\"[/tornado]. Ja m'entens. No tan malament."],
	[0.3, TEXTE, "[color=lightblue]Com deia, vols anar, diguem, a la feina."],
	[0.1, TEXTE, "[color=lightblue]Doncs si vivies a un dels barris més poblats,"],
	[0.1, TEXTE, "[color=lightblue]i volies anar al complex insustrial més gran,"],
	[0.1, TEXTE, "[color=lightblue]doncs tenies un bus cada sis minuts."],
	[0.5, TEXTE, "[color=lightblue]Però ara no. Ara pel teu barri no en passa cap."],
	[0.1, TEXTE, "[color=lightblue]Has d'anar al centre a peu, i allà agafar el bus."],
	[0.1, TEXTE, "[color=lightblue]El qual passa cada 15 minuts."],
	[0.1, TEXTE, "[color=lightblue]Que ha de passar per tots els punts turístics."],
	[0.1, TEXTE, "[color=lightblue]I que va sempre amb retard."],
	[0.1, TEXTE, "[color=lightblue]Però eh, als informes diuen cada cop més passatgers."],
	[0.5, TEXTE, "[color=lightblue]I ja no parlem del metro. O del tramvia."],
	[0.1, TEXTE, "[color=lightblue][tornado]\"Oh, sí, una línia nova.\"[/tornado] I un rave!"],
	[0.1, TEXTE, "[color=lightblue]Els trens van amb retard dia sí, dia també."],
	[0.1, TEXTE, "[color=lightblue]No calen línies de tram noves per on ja passa el bus."],
	[0.1, TEXTE, "[color=lightblue]I el metro."],
	[0.1, TEXTE, "[color=lightblue]I el ferrocarril."],
	[0.1, TEXTE, "[color=lightblue]Fent exactament el mateix recorregut."],
	[1.0, TEXTE, "[color=lightblue]Ui, perdona'm per donar-te la xapa. Aquest és el meu."],
	[0.5, BUS], # BUS 4
	[2.0, TEXTE, "[i]Sembla que m'he quedat sol..."],
	[1.0, TEXTE, "[i]Oh mira, per aqui vé el meu bus, per fi..."],
	[1.0, TEXTE, "[i]Almenys tindré un viatge tranquil..."],
	[0.1, PERSONATGE, 5, DRETA, SOLDIER],
	[0.1, PERSONATGE, 5, ESQUERRA, MALE],
	[0.1, PERSONATGE, 5, DRETA, FEMALE],
	[0.1, PERSONATGE, 5, ESQUERRA, ADVENTURER],
	[0.1, PERSONATGE, 5, DRETA, MALE],
	[0.5, TEXTE, "[i]..."],
	[0.5, TEXTE, "[i]Merda."],
	[0.1, BUS] # BUS 5
	]


func ensurt():
	jumpscare.visible = true;
	jumpscare.play();
	reproductorFX.play();


func fadeIn():
	rectFadeIn.color = Color(.0,.0,.0,1.);
	var tweenFadeIn = create_tween();
	tweenFadeIn.tween_property(rectFadeIn, "color", Color(.0, .0, .0, .0), 1.);
	tweenFadeIn.tween_callback(canvasFadeIn.queue_free);


func arribadaJugador():
	jugador.position = Vector2(2100.0,900.0);
	jugador.flip_h = true;
	var tweenArribadaJugador = create_tween();
	tweenArribadaJugador.tween_property(jugador, "position", Vector2(1600.0, 900.0), 3.0);
	await tweenArribadaJugador.finished;
	jugador.play("Idle");


func createText(missatge: String):
	if (texteActiu): return;
	texteActiu = true;
	etiqueta.text = missatge;
	
	contenidorEtiqueta.size = etiqueta.get_theme_font("font")				\
					.get_string_size(regexBBcode.sub(missatge, "", true),
					HORIZONTAL_ALIGNMENT_LEFT, -1, 64) + Vector2(40,10);
	contenidorEtiqueta.visible = true;
	var tweenMidaEtiqueta = create_tween();
	tweenMidaEtiqueta.tween_property(contenidorEtiqueta, "scale", Vector2(1,1), .25);


func escriuMultiple():
	etiqueta.text = "";
	for i in esdeveniments[progres][4].size():
		if i == seleccionat:
			etiqueta.append_text("[b]%s[/b]\n" % esdeveniments[progres][2][i]);
		else:
			etiqueta.append_text("%s\n" % esdeveniments[progres][2][i]);


func createMultiple(missatges: Array):
	multipleActiu = true;
	seleccionat = 0;
	var maxsize = 0;
	var mida = Vector2();
	
	for frase in missatges:
		mida = etiqueta.get_theme_font("font")				\
					.get_string_size(regexBBcode.sub(frase, "", true),
					HORIZONTAL_ALIGNMENT_LEFT, -1, 64);
		maxsize = max (maxsize, mida.x);
		if seleccionat == 0:
			etiqueta.text = "[b]%s[/b]\n" % missatges[0];
		else:
			etiqueta.append_text("%s\n" % missatges[seleccionat]);
		seleccionat += 1;
	seleccionat = 0;
	contenidorEtiqueta.size = Vector2(40 + maxsize * 1.1, 10 + mida.y * missatges.size());
	contenidorEtiqueta.visible = true;
	var tweenMidaEtiqueta = create_tween();
	tweenMidaEtiqueta.tween_property(contenidorEtiqueta, "scale", Vector2(1,1), .25);


func arribaBus():
	autobus.position = Vector2(-600.0,750.0);
	var tweenArribadaBus = create_tween();
	tweenArribadaBus.tween_property(autobus, "position", Vector2(1220.0, 750.0), 2.0)	\
					.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT);
	await tweenArribadaBus.finished;
	
	if progres == esdeveniments.size() - 1:
		potEntrar = true;
	else:
		tempSortidaBus.wait_time = 2.5;
		tempSortidaBus.start();
	var posLlistat = 0;
	while posLlistat < llistatEsperants.size():
		if llistatEsperants[posLlistat] != null &&\
		llistatEsperants[posLlistat].busObjectiu == busActual :
			llistatEsperants[posLlistat].flip_h = false;
			llistatEsperants[posLlistat].z_index = 4;
			llistatEsperants[posLlistat].play("Walk");
			var tweenCaminarBus = create_tween();
			tweenCaminarBus.tween_property(llistatEsperants[posLlistat], "position",
											Vector2(1600.,760.), 0.5*(posLlistat+1));
			tweenCaminarBus.tween_callback(llistatEsperants[posLlistat].setIdle);
			tweenCaminarBus.tween_property(llistatEsperants[posLlistat], "modulate",
											Color(0.,0.,0.,0.), 0.5);
			tweenCaminarBus.tween_callback(llistatEsperants[posLlistat].queue_free)
			llistatEsperants[posLlistat] = null;
		posLlistat += 1;


func sortidaBus():
	var tweenSortidaBus = create_tween();
	tweenSortidaBus.tween_property(autobus, "position", Vector2(3000.0, 750.0), 2.0)\
					.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN).set_delay(2.);
	await tweenSortidaBus.finished;
	busActual += 1;
	properEsdeveniment();


func arribaPersonatge(busObj :int, dreta :bool, PersonatgeID :int):
	var posLlistat = 0;
	while posLlistat < llistatEsperants.size():
		if llistatEsperants[posLlistat] == null:
			break;
		posLlistat += 1;
		if posLlistat == llistatEsperants.size():
			return;
	
	var tempEsperador = escenaViandant.instantiate();
	add_child(tempEsperador);
	llistatEsperants[posLlistat] = tempEsperador;
	
	var tweenArribadaViandant = create_tween();
	tempEsperador.busObjectiu = busObj;
	tempEsperador.z_index = 5;
	tempEsperador.sprite_frames = spritesViandants[PersonatgeID%5];
	tempEsperador.play("Walk");
	if dreta:
		tempEsperador.position = Vector2(2100.0,900.0);
		tempEsperador.flip_h = true;
		tweenArribadaViandant.tween_property(tempEsperador, "position", Vector2(1426.0-posLlistat*174.0, 900.0),
								3.0+posLlistat + randf_range(-1.,1.));
	else:
		tempEsperador.position = Vector2(-100.0,900.0);
		tempEsperador.flip_h = false;
		tweenArribadaViandant.tween_property(tempEsperador, "position", Vector2(1426.0-posLlistat*174.0, 900.0),
								8.0-posLlistat + randf_range(-1.,1.));
	await tweenArribadaViandant.finished;
	tempEsperador.play("Idle");
	properEsdeveniment();


func _on_temp_esdeveniment_aleatori_timeout() -> void:
	match randi()%3:
		VIANDANT:
			var viandant = escenaViandant.instantiate();
			add_child(viandant);
			viandant.sprite_frames = spritesViandants[randi()%5];
			viandant.play("Walk");
			var origx;
			var destx;
			var posy;
			if randi()%2:
				#dreta a esquerra
				viandant.flip_h = true;
				origx = 2100.;
				destx = -100.;
			else:
				#esquerra a dreta
				viandant.flip_h = false;
				origx = -100.;
				destx = 2100.;
			if randi()%2:
				#dalt
				posy = 380.;
				viandant.modulate = Color(.8,.8,.8,1.);
				viandant.z_index = 1;
			else:
				#baix
				posy = 950.;
				viandant.modulate = Color(.9,.9,.9,1.);
				viandant.z_index = 6;
			viandant.position = Vector2(origx, posy);
			var tweenViandant = create_tween();
			tweenViandant.tween_property(viandant, "position", Vector2(destx, posy), randfn(8.,2.));
			tweenViandant.tween_callback(viandant.queue_free);
		COTXE:
			var cotxe = escenaCotxe.instantiate();
			add_child(cotxe);
			cotxe.z_index = 2;
			cotxe.modulate = Color(.9,.9,.9,1.);
			cotxe.position = Vector2(-200,620);
			var tweenCotxe = create_tween();
			tweenCotxe.tween_property(cotxe, "position", Vector2(2130, 620), 2.3);
			tweenCotxe.tween_callback(cotxe.queue_free);


func _on_temp_sortida_bus_timeout() -> void:
	sortidaBus();


func _on_temps_nou_esdeveniment_timeout() -> void:
	match esdeveniments[progres][1]:
		PERSONATGE:
			arribaPersonatge(esdeveniments[progres][2], esdeveniments[progres][3], esdeveniments[progres][4]);
		BUS:
			arribaBus();
		TEXTE:
			createText(esdeveniments[progres][2]);
		MULTIPLE:
			createMultiple(esdeveniments[progres][2]);
		SKIP:
			progres += esdeveniments[progres][2];
			properEsdeveniment();


func _on_jumpscare_animation_finished() -> void:
	get_tree().quit();


func properEsdeveniment():
	progres += 1;
	tempNouEsdeveniment.wait_time = esdeveniments[progres][0];
	tempNouEsdeveniment.start();


func _input(event):
	if event.is_action_pressed("Amunt"):
		if multipleActiu:
			seleccionat -= 1;
			if seleccionat < 0:
				seleccionat = esdeveniments[progres][4].size() - 1;
			escriuMultiple();
	if event.is_action_pressed("Avall"):
		if multipleActiu:
			seleccionat += 1;
			if seleccionat >= esdeveniments[progres][4].size():
				seleccionat = 0;
			escriuMultiple();
	if event.is_action_pressed("Accio"):
		if potEntrar:
			ensurt();
		if texteActiu:
			var tweenMidaEtiqueta = create_tween();
			tweenMidaEtiqueta.tween_property(contenidorEtiqueta, "scale", Vector2(0,0), .25);
			await tweenMidaEtiqueta.finished;
			texteActiu = false;
			properEsdeveniment();
		if multipleActiu:
			var tweenMidaEtiqueta = create_tween();
			tweenMidaEtiqueta.tween_property(contenidorEtiqueta, "scale", Vector2(0,0), .25);
			await tweenMidaEtiqueta.finished;
			multipleActiu = false;
			var tempString = esdeveniments[progres][3][seleccionat]
			progres += esdeveniments[progres][4][seleccionat];
			createText(tempString);


func _ready() -> void:
	llistatEsperants = [null,null,null,null,null,null,null];
	busActual = 0;
	potEntrar = false;
	escenaViandant = preload("res://Escenes/persona_caminant.tscn");
	escenaCotxe = preload("res://Escenes/cotxe.tscn");
	spritesViandants = [preload("res://Imatges/Characters/Adventurer.tres"),
						preload("res://Imatges/Characters/Female.tres"), 
						preload("res://Imatges/Characters/Player.tres"),
						preload("res://Imatges/Characters/Soldier.tres"), 
						preload("res://Imatges/Characters/Zombie.tres")];
	texteActiu = false;
	multipleActiu = false;
	regexBBcode = RegEx.new()
	regexBBcode.compile("\\[.*?\\]")
	progres = 0;
	
	contenidorEtiqueta.visible = false;
	contenidorEtiqueta.scale = Vector2();
	
	fadeIn();
	arribadaJugador();
	
	tempNouEsdeveniment.wait_time = esdeveniments[progres][0];
	tempNouEsdeveniment.start();


func _process(_delta: float) -> void:
	pass
