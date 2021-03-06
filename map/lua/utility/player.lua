	player = {}

	local player = player
	setmetatable(player, player)

	--结构
	player.__index = {
		--类型
		type = 'player',

		--句柄
		handle = 0,

		--id
		id = 0,

		--获取id
		get = function(this)
			return this.id
		end,

		--是否是玩家
		isPlayer = function(this)
			return jass.GetPlayerController(this.handle) == jass.MAP_CONTROL_USER and jass.GetPlayerSlotState(this.handle) == jass.PLAYER_SLOT_STATE_PLAYING
		end,

		--设置颜色
		setColor = function(this, c)
			jass.SetPlayerColor(this.handle, c)
		end,
	}

	
	function player.__call(_, i)
		return player[i]
	end

	--句柄转玩家
	player.j = {}
	function player.j_player(jPlayer)
		return player.j[jPlayer]
	end

	--注册玩家
	function player.create(id, jPlayer)
		local p = {}
		setmetatable(p, player)

		--初始化
			--句柄
			p.handle = jPlayer
			player.j[jPlayer] = p
			
			--id
			p.id = id
		
		player[id] = p
		return p
	end
	
	--预设玩家
	function player.init()
		for i = 1, 16 do
			player.create(i, jass.Player(i - 1))
		end
	end

	player.init()

	--一些常用事件
	local trg
	local func

	---单位发布物体目标指令
	trg = jass.CreateTrigger()
	
	function func()
		event.start('玩家_聊天', {player = player.j_player(jass.GetTriggerPlayer()), string = jass.GetEventPlayerChatString()})
	end
	
	for i = 1, 16 do
		jass.TriggerRegisterPlayerChatEvent(trg, player[i].handle, '', false)
	end

	jass.TriggerAddCondition(trg, jass.Condition(func))