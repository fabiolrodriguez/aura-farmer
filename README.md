# Aura Farmer

Projeto Godot 4 em GDScript para um incremental game humorístico focado em evolução visual do personagem.

## Como abrir

1. Abra o Godot 4.
2. Importe a pasta do projeto.
3. Rode a cena principal definida em `project.godot`: `res://Scenes/MainMenu/MainMenu.tscn`.

## Arquitetura

Todos os managers são autoloads configurados em `project.godot`.

- `GameManager`: Aura atual, Aura total, Aura por clique, Aura por segundo, multiplicador global, prestígio e progresso offline.
- `UpgradeManager`: catálogo de upgrades, preços exponenciais, níveis e compra.
- `SaveManager`: carregamento, autosave e save ao fechar.
- `AudioManager`: efeitos sonoros procedurais, som de compra com moeda/caixa, power-up de estágio e música de fundo em loop.
- `EffectsManager`: texto flutuante e partículas de clique.
- `AchievementManager`: conquistas locais com IDs preparados para integração futura com Steam.
- `UIManager`: referência da cena de jogo ativa.
- `LocalizationManager`: textos em português e inglês.
- `SettingsManager`: idioma, volume, fullscreen e movimento reduzido.
- `NumberFormatter`: abreviações numéricas como `10K`, `1M`, `2.5B`, `Qa`, `Qi`.
- `AuraEvolutionManager`: estágios visuais baseados na Aura total.

## Cenas Criadas

- `Scenes/MainMenu/MainMenu.tscn`
  - Script: `Scripts/UI/MainMenu.gd`
  - Nós: `Control` raiz. O script monta fundo, logo e botões.
  - Sinais: botões conectados por script para jogar, conquistas, configurações e sair.

- `Scenes/Achievements/Achievements.tscn`
  - Script: `Scripts/UI/AchievementsScreen.gd`
  - Nós: montados por script com progresso geral e cards de badges.
  - Sinais: escuta idioma e alterações de conquistas.

- `Scenes/Game/Game.tscn`
  - Script: `Scripts/UI/GameScreen.gd`
  - Nós: `Background`, `GymBackground`, labels de status, medidor de Essência, `Character`, `ShopPanel`, `MusicButton`, `PopupLayer`.
  - Sinais: conecta sinais dos managers para atualizar HUD, estágio, prestígio, mute de música, animação de compra, popup offline e pause via ESC.

- `Scenes/Character/Character.tscn`
  - Script: `Scripts/Components/CharacterController.gd`
  - Nós: `Node2D`, `ClickArea`, `CollisionShape2D`, `Shadow`, `CharacterSprite`, `AccessoryOverlay`.
  - Sinais: `ClickArea.input_event` dispara clique, squash/stretch, Aura, texto flutuante e partículas.

- `Scenes/Shop/Shop.tscn`
  - Script: `Scripts/UI/ShopPanel.gd`
  - Nós: título, `ScrollContainer`, `Rows`.
  - Sinais: escuta mudanças de Aura, upgrades e idioma.

- `Scenes/Shop/UpgradeRow.tscn`
  - Script: `Scripts/UI/UpgradeRow.gd`
  - Nós: ícone, nome, descrição, nível, preço e botão comprar.
  - Sinais: botão compra o upgrade, anima hover e pulso.

- `Scenes/Settings/Settings.tscn`
  - Script: `Scripts/UI/SettingsScreen.gd`
  - Nós: montados pelo script.
  - Sinais: idioma, volume, movimento reduzido e voltar.

- `Scenes/Popup/OfflinePopup.tscn`
  - Script: `Scripts/UI/OfflinePopup.gd`
  - Nós: título, corpo e botão fechar.
  - Sinais: botão fecha o popup.

- `Scenes/FloatingText/FloatingText.tscn`
  - Script: `Scripts/Components/FloatingText.gd`
  - Responsável pelo texto `+Aura` animado.

- `Scenes/Particles/ClickParticles.tscn`
  - Script: `Scripts/Components/ParticleBurst.gd`
  - Responsável pelas partículas de clique.

## Dados

- `Resources/upgrades_data.gd`: todos os upgrades, preços, crescimento, categorias e efeitos.
- `Resources/aura_stages_data.gd`: estágios visuais, thresholds, cores, partículas e orbitais.
- `Resources/achievements_data.gd`: catálogo de conquistas, incluindo IDs internos e IDs Steam.
- `Assets/Sprites/Character/main_character.png`: sprite principal transparente do personagem.
- `Assets/Sprites/Character/upgraded_character.png`: skin completa com óculos, corrente e tênis, ativada por upgrades visuais.
- `Assets/Sprites/Character/golden_overdrive_character.png`: skin intermediária ativada aos 500k de Aura.
- `Assets/Sprites/Character/legendary_character.png`: skin lendária ativada a partir de 1 milhão de Aura.
- `Assets/Sprites/Character/legendary_drip_character.png`: variação lendária com óculos, corrente, tênis premium e aura dourada ativada a partir de 10 milhões de Aura.
- `Assets/Sprites/Character/heroic_champion_character.png`: skin de campeão ancestral ativada a partir de 2 milhões de Aura.
- `Assets/Sprites/Character/cosmic_character.png`: skin cósmica ativada em 10 bilhões de Aura.
- `Assets/Sprites/Character/cosmic_1_character.png` ate `cosmic_9_character.png`: progressão cósmica de 100M a 900M de Aura, com `cosmic_500m_character.png` como marco especial.
- `Assets/Sprites/Character/void_emperor_character.png`: forma de imperador do vazio ativada em 1 trilhão de Aura.
- `Assets/UI/Logo/aura_farmer_67_logo.png`: logo da tela inicial.
- `Assets/UI/Icon/aura_farmer_icon_1024.png`: ícone configurado no projeto Godot.
- `Assets/Marketing/Steam/`: capsules, artes de biblioteca, ícones e artes de evento para Steamworks.

## Cenário

`Scripts/Components/GymBackground.gd` desenha um cenário neonwave por código, sem sprites externos. A camada mantém o chão em perspectiva como elemento principal, com sol no horizonte, montanhas wireframe, estrelas sutis, reflexo e grade neon. O fundo usa baixa opacidade para manter o personagem como foco principal.

Skins principais usam imagens completas para evitar desalinhamento de acessórios. `Scripts/Components/CharacterAccessoryOverlay.gd` fica reservado para efeitos abstratos pequenos, como brilho de café, creatina e aura sigma.

## Pause

Durante o jogo, `ESC` abre um menu de pause por overlay. O menu permite continuar, abrir configurações compactas sem sair da partida ou salvar e voltar para o menu inicial.

## Conquistas

As conquistas são salvas junto com o progresso e expostas pela tela `Scenes/Achievements/Achievements.tscn`. O catálogo tem 30 badges, começando com objetivos pequenos e terminando na platina. Para integração com Steam, conecte uma ponte compatível usando `AchievementManager.set_steam_bridge()`. O exemplo em `Scripts/Integrations/SteamAchievementBridge.gd` espera um objeto de API com métodos `setAchievement` e `storeStats`.

## Áudio

O áudio é gerado por código em `AudioManager.gd`, sem samples externos. A música de fundo é um loop original de batida urbana/academia, controlada por `music_enabled` e `music_volume` nas configurações.
- `Resources/settings_data.gd`: configurações padrão.

Para adicionar um upgrade, inclua um novo dicionário em `Resources/upgrades_data.gd` e adicione as chaves de texto em `LocalizationManager.gd`.

Categorias de upgrade:

- `click`: aumenta Aura por clique.
- `auto`: adiciona farm automático de Aura por segundo.
- `multiplier`: aumenta o multiplicador global de geração.

Para adicionar um estágio visual, inclua um novo dicionário em `Resources/aura_stages_data.gd` e adicione as chaves de texto em `LocalizationManager.gd`.

Cada estágio pode ajustar `character_scale`, que controla o tamanho do personagem nos checkpoints de Aura.

Estágios também podem definir `character_texture` para trocar a skin principal. Upgrades visuais importantes usam skins completas para evitar desalinhamento; efeitos menores continuam em `Scripts/Components/CharacterAccessoryOverlay.gd`.
