-- KyoryokunaPlates
-- Copyright (c) 2026 Pragas. All Rights Reserved.
-- See LICENSE for terms. Unauthorized copying, modification or redistribution is prohibited.

-- Portuguese (Portugal). Each English text of the addon and its translation; a text missing here shows
-- in English. Chosen on the General page.

local _, ns = ...

ns.LOCALES.ptPT = {
	-- Pages
	["General"] = "Geral",
	["Enemies"] = "Inimigos",
	["Target"] = "Alvo",
	["Cast Bar"] = "Barra de cast",
	["Allies"] = "Aliados",
	["About"] = "Sobre",

	-- General
	["Language"] = "Idioma",
	["The language of the addon's texts."] = "O idioma dos textos do addon.",
	["Test mode"] = "Modo de teste",
	["Example nameplates for every case, to see how the options look without having to find each case in the game. They follow every change at once."] =
		"Nameplates de exemplo para todos os casos, para veres como ficam as opções sem teres de encontrar cada caso no jogo. Acompanham cada alteração na hora.",
	["Open the test mode"] = "Abrir o modo de teste",
	["Also with /kp test."] = "Também com /kp test.",
	["Nameplates"] = "Nameplates",
	["Manage the game's nameplate settings"] = "Gerir as definições de nameplates do jogo",
	["Lets this addon set the game's own nameplate settings: width, target size, which nameplates show, class colors, name-only allies and click-through. Turning it off puts back the values they had before."] =
		"Deixa este addon mudar as definições de nameplates do próprio jogo: largura, tamanho do alvo, que nameplates aparecem, cores de classe, aliados só com o nome e clicar através. Desligado, repõe os valores que tinham antes.",
	["Width"] = "Largura",
	["Stack enemy nameplates"] = "Empilhar as nameplates dos inimigos",
	["Off, the nameplates of mobs close together overlap, and the game keeps swapping which one is in front, so a bar can seem to jump up and down. On, the game pushes them apart so they never overlap."] =
		"Desligado, as nameplates de mobs juntos sobrepõem-se e o jogo vai trocando qual fica à frente, por isso uma barra pode parecer saltar para cima e para baixo. Ligado, o jogo afasta-as para nunca se sobreporem.",
	["Target size"] = "Tamanho do alvo",
	["How much bigger the nameplate of your target is. Needs \"Manage the game's nameplate settings\" on the General page."] =
		"Quanto maior fica a nameplate do teu alvo. Precisa de \"Gerir as definições de nameplates do jogo\" na página Geral.",
	["Minimap"] = "Minimapa",
	["Show the minimap button"] = "Mostrar o botão no minimapa",
	["A click on it opens the options. Drag it to move it around the minimap."] =
		"Um clique abre as opções. Arrasta-o para o mudares de sítio à volta do minimapa.",
	["Support"] = "Suporte",
	["Tell me in the chat when an error happens"] = "Avisar no chat quando acontece um erro",
	["Errors are always kept. Read them with /kp errors."] = "Os erros ficam sempre guardados. Lê-os com /kp errors.",
	["Show recorded errors"] = "Mostrar os erros registados",
	["Delete recorded errors"] = "Apagar os erros registados",
	["Asks for confirmation first. Also with /kp clearerrors."] = "Pede confirmação primeiro. Também com /kp clearerrors.",
	["Delete the %d recorded error(s)? This can't be undone."] = "Apagar os %d erro(s) registado(s)? Não dá para desfazer.",
	["Yes"] = "Sim",
	["No"] = "Não",
	["Default"] = "Padrão",
	["Puts this color back to its default."] = "Repõe esta cor no padrão.",
	["Diagnostics of my target"] = "Diagnóstico do meu alvo",
	["Prints in the chat what the game lets the addon see about your current target."] =
		"Escreve no chat o que o jogo deixa o addon ver sobre o teu alvo atual.",

	-- Enemies
	["Look"] = "Aspeto",
	["Right-click to type a value."] = "Clique direito para escrever um valor.",
	["Bar width"] = "Largura da barra",
	["The width of the health bar. The nameplates follow it when the addon manages the game's nameplate settings."] =
		"A largura da barra de vida. As nameplates acompanham-na quando o addon gere as definições de nameplates do jogo.",
	["Bar height"] = "Altura da barra",
	["The height of the health bar."] = "A altura da barra de vida.",
	["Show the health percent"] = "Mostrar a percentagem de vida",
	["Health percent position"] = "Posição da percentagem de vida",
	["Where the health percent sits: inside the bar, or outside it. Outside on the same side as the level, it comes after the level."] =
		"Onde fica a percentagem de vida: dentro da barra ou fora dela. Fora, do mesmo lado que o nível, fica a seguir ao nível.",
	["Show the level"] = "Mostrar o nível",
	["Level position"] = "Posição do nível",
	["Inside, left"] = "Dentro, à esquerda",
	["Inside, center"] = "Dentro, ao centro",
	["Inside, right"] = "Dentro, à direita",
	["Outside, left"] = "Fora, à esquerda",
	["Outside, right"] = "Fora, à direita",
	["Players in their class color"] = "Jogadores na cor da classe",
	["The health bar and the name of enemy players."] = "A barra de vida e o nome dos jogadores inimigos.",
	["Name size"] = "Tamanho do nome",
	["A percentage of the game's own size."] = "Uma percentagem do tamanho do próprio jogo.",
	["Level next to the bar"] = "Nível ao lado da barra",
	["Quest icon on quest mobs"] = "Ícone de quest nos mobs de quest",
	["A yellow \"!\" left of the bar of mobs that belong to one of your active quests."] =
		"Um \"!\" amarelo à esquerda da barra dos mobs que fazem parte de uma das tuas quests ativas.",
	["Threat"] = "Ameaça",
	["Threat glow above the bar"] = "Brilho de ameaça por cima da barra",
	["The game's orange glow above the health bar of a mob that's attacking you, or that you're about to pull. Needs \"Manage the game's nameplate settings\" (General page)."] =
		"O brilho laranja do jogo por cima da barra de vida de um mob que te está a atacar, ou que estás quase a puxar. Precisa de \"Gerir as definições de nameplates do jogo\" (página Geral).",
	["Flash when gaining or losing aggro"] = "Flash ao ganhar ou perder o aggro",
	["The game's short flash on the health bar when a mob starts or stops attacking you. Needs \"Manage the game's nameplate settings\" (General page)."] =
		"O flash curto do jogo na barra de vida quando um mob começa ou deixa de te atacar. Precisa de \"Gerir as definições de nameplates do jogo\" (página Geral).",
	["My debuffs"] = "Os meus debuffs",
	["Show my debuffs above the name"] = "Mostrar os meus debuffs por cima do nome",
	["My crowd control first"] = "Os meus CC primeiro",
	["Your stuns, roots, fears, sleeps and other controls (what the game counts as crowd control) come first in the row."] =
		"Os teus stuns, roots, fears, sleeps e outros controlos (o que o jogo conta como controlo de grupo) ficam primeiro na fila.",
	["Crowd control border in its own color"] = "Contorno dos CC com cor própria",
	["Every icon has a black border; this gives the crowd control ones a color of their own. Needs \"My crowd control first\": only then can the addon tell them apart."] =
		"Todos os ícones têm um contorno preto; isto dá aos de CC uma cor própria. Precisa de \"Os meus CC primeiro\": só assim o addon os consegue distinguir.",
	["Crowd control border color"] = "Cor do contorno dos CC",
	["Where the row of icons sits over the health bar: from its left end, or from its right end."] =
		"Onde fica a fila de ícones por cima da barra de vida: a partir da ponta esquerda ou a partir da ponta direita.",
	["Icon size"] = "Tamanho dos ícones",
	["Most icons"] = "Máximo de ícones",
	["Height above the bar"] = "Altura acima da barra",

	-- Target
	["Arrow"] = "Seta",
	["Arrow on the target"] = "Seta no alvo",
	["Arrow position"] = "Posição da seta",
	["Above"] = "Por cima",
	["Both sides"] = "Dos dois lados",
	["On the top edge of the target's health bar, pointing down, or on its left or right edge (or both), pointing at it: always half inside and half outside the bar."] =
		"Na borda de cima da barra de vida do alvo, a apontar para baixo, ou na borda esquerda ou direita (ou nas duas), a apontar para ela: sempre metade dentro e metade fora da barra.",
	["Above: moves the arrow to the left or right. On the sides: moves the arrows away from the bar, or into it with a negative value."] =
		"Por cima: move a seta para a esquerda ou para a direita. Nos lados: afasta as setas da barra, ou mete-as para dentro com um valor negativo.",
	["Arrow size"] = "Tamanho da seta",
	["Left / right"] = "Esquerda / direita",
	["Down / up"] = "Baixo / cima",
	["Health bar"] = "Barra de vida",
	["Border color of the target"] = "Cor do contorno do alvo",
	["Who they target"] = "Quem têm como alvo",
	["Show who each enemy is targeting"] = "Mostrar quem cada inimigo tem como alvo",
	["Under the right end of the bar, in the class color of players. While the enemy casts, the target of the cast, under the cast bar."] =
		"Por baixo do fim da barra, à direita, na cor da classe dos jogadores. Enquanto o inimigo faz cast, o alvo do cast, por baixo da barra de cast.",

	-- Cast bar
	["Colors"] = "Cores",
	["Interrupt ready"] = "Interrupt pronto",
	["Can be interrupted"] = "Dá para interromper",
	["A cast you can interrupt: your interrupt is ready (or you don't have one)."] =
		"Um cast que podes interromper: o teu interrupt está pronto (ou não tens nenhum).",
	["My interrupt on cooldown"] = "O meu interrupt em cooldown",
	["A cast that could be interrupted, but your interrupt is on cooldown."] =
		"Um cast que dava para interromper, mas o teu interrupt está em cooldown.",
	["Can't be interrupted"] = "Não dá para interromper",
	["Spells that can never be interrupted."] = "Spells que nunca dá para interromper.",
	["Spell"] = "Feitiço",
	["Show the spell icon"] = "Mostrar o ícone do feitiço",
	["Show the spell name"] = "Mostrar o nome do feitiço",
	["Spell icon position"] = "Posição do ícone do feitiço",
	["Inside the left or the right end of the cast bar."] = "Dentro da ponta esquerda ou da ponta direita da barra de cast.",
	["Spell name position"] = "Posição do nome do feitiço",
	["At the left, in the middle or at the right of the cast bar. On the side of the icon, it starts after the icon."] =
		"À esquerda, ao centro ou à direita da barra de cast. Do lado do ícone, começa a seguir ao ícone.",
	["Center"] = "Ao centro",
	["100% is as tall as the cast bar."] = "100% é da altura da barra de cast.",
	["Join to the health bar"] = "Juntar à barra de vida",
	["Right under the health bar, just as wide, sharing its border. Off, the cast bar has its own width and distance."] =
		"Logo debaixo da barra de vida, com a mesma largura e a borda partilhada. Desligado, a barra de cast tem a sua própria largura e distância.",
	["Distance from the health bar"] = "Distância da barra de vida",
	["Horizontal position"] = "Posição horizontal",
	["0 is centered under the health bar."] = "0 é ao centro, debaixo da barra de vida.",
	["Bar"] = "Barra",
	["Height"] = "Altura",
	["Spell icon size"] = "Tamanho do ícone do feitiço",
	["Spell name size"] = "Tamanho do nome do feitiço",
	["Hide on allies"] = "Esconder nos aliados",

	-- Raid marks
	["Raid Marks"] = "Marcas de raid",
	["Where the raid mark (skull, cross, square...) shows on the nameplates, and how big, for enemies and allies apart."] =
		"Onde aparece a marca de raid (caveira, cruz, quadrado...) nas nameplates, e o seu tamanho, para inimigos e aliados em separado.",
	["The size of the mark. Like the nameplate, it's bigger on your target."] =
		"O tamanho da marca. Tal como a nameplate, fica maior no teu alvo.",
	["Left or right: beside the health bar, past the level, the health percent and the icons shown on that side; beside the name when only the name shows."] =
		"Esquerda ou direita: ao lado da barra de vida, depois do nível, da percentagem e dos ícones que estejam desse lado; ao lado do nome quando só se vê o nome.",
	["Left or right: beside the health bar (past the role icon when it's on that side), or beside the name when it's name only."] =
		"Esquerda ou direita: ao lado da barra de vida (depois do ícone de função, quando está desse lado), ou ao lado do nome quando é só nome.",
	["Inside dungeons and raids the game doesn't let addons change the nameplates of allies: there their mark stays where the game puts it, in the game's size."] =
		"Dentro de dungeons e raids o jogo não deixa os addons mexerem nas nameplates dos aliados: aí a marca fica onde o jogo a põe, com o tamanho do jogo.",

	-- Allies
	["Inside dungeons and raids the game doesn't let addons change the nameplates of allies. There only name only and the class colors apply."] =
		"Dentro de dungeons e raids o jogo não deixa os addons mexerem nas nameplates dos aliados. Aí só contam o só nome e as cores de classe.",
	["Players"] = "Jogadores",
	["Name only (no health bar)"] = "Só o nome (sem barra de vida)",
	["Click through allies"] = "Clicar através dos aliados",
	["Clicking the name of an ally doesn't select them; you select them on their character or the party frames."] =
		"Clicar no nome de um aliado não o seleciona; selecionas no boneco ou nos party frames.",
	["100% is the normal size."] = "100% é o tamanho normal.",
	["Health percent size"] = "Tamanho da percentagem de vida",
	["Level size"] = "Tamanho do nível",
	["Name height"] = "Altura do nome",
	["How high above the player's head the name sits, with name only. Lower brings it closer to the head."] =
		"A que altura da cabeça do jogador fica o nome, com só o nome. Mais baixo aproxima-o da cabeça.",
	["100% is the normal size. Inside the bar, it's never taller than the bar."] =
		"100% é o tamanho normal. Dentro da barra, nunca fica mais alto do que a barra.",
	["100% is the normal size of the name. Inside the bar, it's never taller than the bar."] =
		"100% é o tamanho normal do nome. Dentro da barra, nunca fica mais alta do que a barra.",
	["Group roles"] = "Funções no grupo",
	["Show the role of players in your group"] = "Mostrar a função dos jogadores do teu grupo",
	["The tank, healer or damage icon next to the name, from the group finder or the role the leader gave."] =
		"O ícone de tank, healer ou DPS ao lado do nome, vindo do dungeon finder ou da função que o líder deu.",
	["Tanks"] = "Tanks",
	["Healers"] = "Healers",
	["Damage"] = "DPS",
	["Position"] = "Posição",
	["Left"] = "À esquerda",
	["Right"] = "À direita",
	["Left or right: beside the health bar, or beside the name when it's name only."] =
		"À esquerda ou à direita: ao lado da barra de vida, ou ao lado do nome quando é só o nome.",
	["Above the name"] = "Por cima do nome",
	["Size"] = "Tamanho",
	["Healer mana"] = "Mana dos healers",
	["Mana bar of healers"] = "Barra de mana dos healers",
	["Under the name. With a health bar, right under the health bar and just as wide."] =
		"Por baixo do nome. Com barra de vida, logo por baixo da barra de vida e com a mesma largura.",
	["With name only."] = "Com só o nome.",
	["Same width as the name"] = "Mesma largura do nome",

	-- About
	["Version"] = "Versão",
	["Author"] = "Autor",
	["How it works"] = "Como funciona",
	["Kyoryokuna Plates doesn't create nameplates of its own. It takes the game's nameplates and changes how they look, so the game keeps handling health, positions, clicks, its threat glow and its health text. That's why it keeps working in combat and with the values the game hides from addons."] =
		"O Kyoryokuna Plates não cria nameplates próprias. Pega nas nameplates do jogo e muda o aspeto delas, por isso o jogo continua a tratar da vida, das posições, dos cliques, do brilho de ameaça e do texto de vida. É por isso que continua a funcionar em combate e com os valores que o jogo esconde aos addons.",
	["Some options are the game's own nameplate settings. You can put them back as they were with \"Manage the game's nameplate settings\" on the General page."] =
		"Algumas opções são definições de nameplates do próprio jogo. Podes repô-las como estavam com \"Gerir as definições de nameplates do jogo\", na página Geral.",
	["Copyright"] = "Direitos de autor",
	["This addon may be used freely for personal use. Copying, modifying or redistributing its code, in whole or in part, is not allowed without written permission from the author. See the LICENSE file for the full terms."] =
		"Este addon pode ser usado livremente para uso pessoal. Não é permitido copiar, modificar ou redistribuir o seu código, no todo ou em parte, sem autorização escrita do autor. Vê o ficheiro LICENSE para os termos completos.",
	["World of Warcraft is a trademark of Blizzard Entertainment, Inc. This addon is not affiliated with or endorsed by Blizzard Entertainment."] =
		"World of Warcraft é uma marca registada da Blizzard Entertainment, Inc. Este addon não é afiliado nem apoiado pela Blizzard Entertainment.",

	-- Test mode
	["The examples follow every change of the options."] = "Os exemplos acompanham cada alteração das opções.",
	["Enemy"] = "Inimigo",
	["Neutral"] = "Neutro",
	["Tapped by others"] = "Tocado por outros",
	["Elite"] = "Elite",
	["Raid mark"] = "Marca de raid",
	["Enemy player"] = "Jogador inimigo",
	["Boss"] = "Boss",
	["Low level"] = "Nível baixo",
	["Cast: can be interrupted"] = "Cast: dá para interromper",
	["Cast: my interrupt on cooldown"] = "Cast: o meu interrupt em cooldown",
	["Cast: can't be interrupted"] = "Cast: não dá para interromper",
	["Ally"] = "Aliado",
	["Ally tank"] = "Aliado tank",
	["Ally healer"] = "Aliado healer",
	["Target casting"] = "Alvo a castar",
	-- Descriptions of the examples
	["A hostile mob from one of your quests"] = "Um mob hostil de uma das tuas quests",
	["Your current target, with your debuffs"] = "O teu alvo atual, com os teus debuffs",
	["Your target casting at someone"] = "O teu alvo a castar contra alguém",
	["Doesn't attack until you do"] = "Só ataca se lhe bateres",
	["Already tagged by another player"] = "Já foi tocado por outro jogador",
	["A stronger mob, with the elite dragon"] = "Um mob mais forte, com o dragão de elite",
	["A mob with a raid mark"] = "Um mob com marca de raid",
	["Quest mob with a raid mark"] = "Mob de quest com marca de raid",
	["The mark goes past the quest icon"] = "A marca fica depois do ícone da quest",
	["Ally with a raid mark"] = "Aliado com marca de raid",
	["A player of your faction, marked"] = "Um jogador da tua fação, marcado",
	["In the color of their class"] = "Na cor da sua classe",
	["Its level shows as a skull"] = "O nível aparece como caveira",
	["Far below your level"] = "Muito abaixo do teu nível",
	["Your interrupt is ready"] = "O teu interrupt está pronto",
	["Your interrupt is on cooldown"] = "O teu interrupt está em cooldown",
	["A spell that can't be interrupted"] = "Um spell que não dá para interromper",
	["A player of your faction"] = "Um jogador da tua fação",
	["No arrow, and it doesn't grow"] = "Sem seta, e não cresce",
	["With the tank role icon"] = "Com o ícone de tank",
	["With the role icon and the mana bar"] = "Com o ícone de healer e a barra de mana",
	["Ally selected"] = "Aliado selecionado",

	-- Chat, minimap and the game's settings
	["All options are in the addon's own window. You can also type /kp."] =
		"Todas as opções estão na janela do próprio addon. Também podes escrever /kp.",
	["Open options"] = "Abrir as opções",
	["Click to open the options."] = "Clica para abrir as opções.",
	["Drag to move this button."] = "Arrasta para mudar este botão de sítio.",
	["The game's nameplate settings were put back."] = "As definições de nameplates do jogo foram repostas.",
	["An error happened. Type /kp errors to see it."] = "Aconteceu um erro. Escreve /kp errors para o veres.",
	["No errors recorded."] = "Nenhum erro registado.",
	["%d error(s) recorded, newest last:"] = "%d erro(s) registado(s), o mais recente no fim:",
	["Errors cleared."] = "Erros apagados.",
	["Commands:"] = "Comandos:",
	["open the options"] = "abrir as opções",
	["test mode: example nameplates for every case"] = "modo de teste: nameplates de exemplo para todos os casos",
	["what the game lets the addon see about your target"] = "o que o jogo deixa o addon ver sobre o teu alvo",
	["show recorded errors"] = "mostrar os erros registados",
	["clear recorded errors"] = "apagar os erros registados",

	-- Diagnostics
	["Diagnostics"] = "Diagnóstico",
	["Instance"] = "Instância",
	["In combat"] = "Em combate",
	["Interrupt"] = "Interrupt",
	["none found"] = "nenhum encontrado",
	["Interrupt last used"] = "Interrupt usado pela última vez",
	["%.1fs ago"] = "há %.1fs",
	["not seen"] = "não visto",
	["none"] = "nenhum",
	["Target nameplate"] = "Nameplate do alvo",
	["not found (no nameplate, or protected by the game)"] = "não encontrada (sem nameplate, ou protegida pelo jogo)",
	["Target nameplate forbidden"] = "Nameplate do alvo protegida",
	["Managed by the addon"] = "Gerida pelo addon",
	["yes"] = "sim",
	["no"] = "não",
	["Name"] = "Nome",
	["Health"] = "Vida",
	["Max health"] = "Vida máxima",
	["Class"] = "Classe",
	["Reaction"] = "Reação",
	["Threat status"] = "Estado da ameaça",
	["Cast end time"] = "Fim do cast",
	["Cast can't be interrupted"] = "Cast não interrompível",
	["Group role"] = "Função no grupo",
	["Quest unit"] = "Unidade de quest",
	["Identity secret"] = "Identidade secreta",
	["secret"] = "secreto",

	-- Import / Export
	["Import / Export"] = "Importar / Exportar",
	["Export"] = "Exportar",
	["A code with all your settings, to share with someone. Click the box (or the button) and press Ctrl+C to copy it. Your language, the minimap button and the error messages aren't in it."] =
		"Um código com todas as tuas definições, para partilhar com alguém. Clica na caixa (ou no botão) e carrega em Ctrl+C para o copiar. A língua, o botão do minimapa e as mensagens de erro não vão no código.",
	["Your code"] = "O teu código",
	["Select the code"] = "Selecionar o código",
	["Press Ctrl+C to copy the code."] = "Carrega em Ctrl+C para copiar o código.",
	["Import"] = "Importar",
	["Paste a code (Ctrl+V) in the box and click Import. Your current settings are kept as a backup first, so you can go back."] =
		"Cola um código (Ctrl+V) na caixa e clica em Importar. Antes disso, as tuas definições atuais ficam guardadas numa cópia de segurança, para poderes voltar atrás.",
	["Code to import"] = "Código a importar",
	["Paste a code in the box first."] = "Cola primeiro um código na caixa.",
	["Replace your settings with the %d from this code? Your current settings are kept as a backup."] =
		"Substituir as tuas definições pelas %d deste código? As tuas definições atuais ficam guardadas numa cópia de segurança.",
	["That isn't a Kyoryokuna Plates code."] = "Isso não é um código do Kyoryokuna Plates.",
	["That code has no settings this version knows."] = "Esse código não tem definições que esta versão conheça.",
	["%d settings imported. Your previous settings were kept as a backup."] =
		"%d definições importadas. As tuas definições anteriores ficaram guardadas numa cópia de segurança.",
	["Backups"] = "Cópias de segurança",
	["Copies of all your settings, to put back if you change something and don't like it. The last 10 are kept; one is also made by itself before an import or a restore."] =
		"Cópias de todas as tuas definições, para repor se mudares alguma coisa e não gostares. Ficam guardadas as últimas 10; também é feita uma automaticamente antes de importar ou repor.",
	["Create a backup"] = "Criar uma cópia de segurança",
	["Name of the backup (optional)"] = "Nome da cópia (opcional)",
	["Edit"] = "Editar",
	["Gives this backup a name of your own. Enter keeps it; an empty name gives it back its first one."] =
		"Dá um nome teu a esta cópia. Enter guarda-o; um nome vazio devolve-lhe o nome que tinha.",
	["Backup created."] = "Cópia de segurança criada.",
	["No backups yet."] = "Ainda não há cópias de segurança.",
	["Backup"] = "Cópia",
	["Before import"] = "Antes de importar",
	["Before restore"] = "Antes de repor",
	["Restore"] = "Repor",
	["Puts these settings back. Your current ones are kept as a backup first."] =
		"Repõe estas definições. Antes disso, as atuais ficam guardadas numa cópia de segurança.",
	["Put back the settings of %s? Your current settings are kept as a backup."] =
		"Repor as definições de %s? As tuas definições atuais ficam guardadas numa cópia de segurança.",
	["Backup of %s restored."] = "Cópia de %s reposta.",
	["Delete"] = "Apagar",
	["Deletes this backup. Asks first."] = "Apaga esta cópia de segurança. Pergunta primeiro.",
	["Delete the backup of %s? This can't be undone."] = "Apagar a cópia de %s? Não dá para desfazer.",
}
