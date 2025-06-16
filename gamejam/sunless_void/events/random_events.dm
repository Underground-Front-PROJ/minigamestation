/obj/structure/sunvoid/event_controller/random_event/carps/run_event()
	for(var/mob/living/basic/sunvoid_ship/ship in get_turf(src))
		to_chat(ship, span_info("Странный скрежет раздражает твоё ухо уже некоторое время. Он доносится извне, и пускай не несёт никакой прямой угрозы..."))
		to_chat(ship, span_info("...ты всё равно решаешь проверить источник. Глядя на картинку, поступающую с внешних камер, ты замечаешь стаю карпов,"))
		to_chat(ship, span_info("плотно присосавшихся к твоей обшивке. Если они продолжат в том же духе - это может привести к серьёзным последствиям."))

		INVOKE_ASYNC(ship, TYPE_PROC_REF(/mob/living/basic/sunvoid_ship, att_choice), ship)

		switch(ship.stat_choice)
			if("STR")

				if(ship.str_stat >= 3)
					to_chat(ship, span_info("Ты решаешь избавиться от них самостоятельно. С гаечным ключом и резаком в обеих руках, ты выходишь в шлюз, включая магнитные ботинки..."))
					to_chat(ship, span_nicegreen("...сегодня у тебя на ужин [span_boldnicegreen("рыба")]."))
					to_chat(ship, span_info(""))
					to_chat(ship, span_binarysay("[span_boldnicegreen("|Стамина|")] полностью восстановлена!"))

					ship.pilot_stamina = ship.pilot_stamina_max
					ship.stop_movement = FALSE
					spawn(5 SECONDS)
						qdel(src)

				if(prob(20))
					to_chat(ship, span_info("Ты решаешь избавиться от них самостоятельно. С гаечным ключом и резаком в обеих руках, ты выходишь в шлюз, включая магнитные ботинки..."))
					to_chat(ship, span_nicegreen("...сегодня у тебя на ужин [span_boldnicegreen("рыба")]."))
					to_chat(ship, span_info(""))
					to_chat(ship, span_binarysay("[span_boldnicegreen("|Стамина|")] полностью восстановлена!"))

					ship.pilot_stamina = ship.pilot_stamina_max
					ship.stop_movement = FALSE
					spawn(5 SECONDS)
						qdel(src)

				to_chat(ship, span_info("Ты решаешь, что тебе хватит сил разобраться с ними самостоятельно..."))
				to_chat(ship, span_danger("...и, в целом, справляешься. Карпы улетают. Но оставив тебе и твоему кораблю [span_bolddanger("серьёзный ущерб")]."))
				to_chat(ship, span_binarysay("-1 [span_bolddanger("|Корпус|")], -2 [span_bolddanger("|Здоровье|")]!"))

				ship.pilot_health -= 1
				ship.hull_health -= 2
				ship.stop_movement = FALSE
				spawn(5 SECONDS)
					qdel(src)

/obj/structure/sunvoid/event_controller/random_event/escape_pod/run_event()
	for(var/mob/living/basic/sunvoid_ship/ship in get_turf(src))
		to_chat(ship, span_info("Пролетая через очередной сектор, на радаре ты замечаешь сигнал бедствия. При более тщательном осмотре, ты обнаруживаешь"))
		to_chat(ship, span_info("вполне себе функционирующую спасательную капсулу, предположительно, с живым существом внутри. Поднимая её на корабль, ты"))
		to_chat(ship, span_info("пытаешься разобраться с установленным электронным замком..."))

		INVOKE_ASYNC(ship, TYPE_PROC_REF(/mob/living/basic/sunvoid_ship, att_choice), ship)

		switch(ship.stat_choice)
			if("INT")
				if(ship.str_stat >= 3)
					to_chat(ship, span_info("Слегка повозившись с мультитулом, ты слышишь щелчок. Капсула открывается, и кто-то внутри начинает жадно глотать воздух."))
					to_chat(ship, span_info("Похоже, ты подобрал офицера Третьего Флота. Но что он делает здесь?...В поту, всё ещё пытаясь отдышаться, он спрашивает, какой сейчас год."))
					to_chat(ship, span_info("Твой ответ не сильно радует его, но смирение с данным фактом наступает быстрее гнева. [span_boldnicegreen("'Тридцать лет...О Селена...'")] - бормочет он себе под нос,"))
					to_chat(ship, span_info("затем поднимая взгляд наверх. [span_boldnicegreen("'Мне понадобится твоя помощь. Скажи, кто-нибудь ещё уцелел?'")]"))
					to_chat(ship, span_info(""))
					to_chat(ship, span_binarysay("Получено новое задание: [span_boldnicegreen("|Старая гвардия|")]. Доставьте офицера ЦПСС в [span_boldnicegreen("|Ястребиное Гнездо|")]."))

					ship.stop_movement = FALSE
					spawn(5 SECONDS)
						qdel(src)

				if(prob(20))
					to_chat(ship, span_info("Слегка повозившись с мультитулом, ты слышишь щелчок. Капсула открывается, и кто-то внутри начинает жадно глотать воздух."))
					to_chat(ship, span_info("Похоже, ты подобрал офицера Третьего Флота. Но что он делает здесь?...В поту, всё ещё пытаясь отдышаться, он спрашивает, какой сейчас год."))
					to_chat(ship, span_info("Твой ответ не сильно радует его, но смирение с данным фактом наступает быстрее гнева. [span_boldnicegreen("'Тридцать лет...О Селена...'")] - бормочет он себе под нос,"))
					to_chat(ship, span_info("затем поднимая взгляд наверх. [span_boldnicegreen("'Мне понадобится твоя помощь. Скажи, кто-нибудь ещё уцелел?'")]"))
					to_chat(ship, span_info(""))
					to_chat(ship, span_binarysay("Получено новое задание: [span_boldnicegreen("|Старая гвардия|")]. Доставьте офицера ЦПСС в [span_boldnicegreen("|Ястребиное Гнездо|")]."))

					ship.stop_movement = FALSE
					spawn(5 SECONDS)
						qdel(src)

				to_chat(ship, span_info("Ты тщетно пытаешься обойти защитную систему и открыть этот чёртов саркофаг, однако..."))
				to_chat(ship, span_info("внезапно, что-то щёлкает внутри механизма, и всю комнату наполняет густой пар. Содержимое капсулы [span_bolddanger("вспыхивает ярким пламенем")]."))
				to_chat(ship, span_info(""))
				to_chat(ship, span_binarysay("Когда капсула всё же открывается, внутри тебя встречает лишь [span_bolddanger("обугленный труп")]. -1 [span_bolddanger("|Стамина|")]."))

				ship.stop_movement = FALSE
				ship.pilot_stamina -= 1
				spawn(5 SECONDS)
					qdel(src)

